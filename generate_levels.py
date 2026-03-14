#!/usr/bin/env python3
"""
Parse Unity .unity level files and generate Godot .tscn scene files.
Uses regex-based parsing (no PyYAML needed) since Unity YAML has custom tags.
Unity: Z+ forward, Godot: Z- forward.
"""

import re
import os
from pathlib import Path

UNITY_DIR = Path("unity-version/Assets")
GODOT_DIR = Path("godot-version/scenes/levels")

OBSTACLE_GUID = "2252c557bf911b54ca7b1d4f98e9b2c8"
THUMP1_GUID = "b6359cdbcd84d7b4995818dbd2cc198a"
THUMP2_GUID = "977dc1728bd34774caec61f211df197f"

LEVEL_END_GOALS = {
    1: 550, 2: 600, 3: 602, 4: 500, 5: 500, 6: 500,
    7: 800, 8: 800, 9: 1000, 10: 500, 11: 550, 12: 850,
    13: 850, 14: 950, 15: 1600,
}

LEVEL_END_TRIGGERS = {
    1: 557, 2: 605, 3: 611, 4: 509, 5: 509, 6: 509,
    7: 809, 8: 809, 9: 1009, 10: 509, 11: 559, 12: 859,
    13: 859, 14: 959, 15: 1609,
}


def parse_prefab_instances(content):
    """Extract PrefabInstance blocks and their position modifications."""
    obstacles = []
    thumps = []

    # Split into document blocks
    blocks = re.split(r'^--- !u!\d+ &\d+', content, flags=re.MULTILINE)
    headers = re.findall(r'^--- !u!(\d+) &(\d+)', content, flags=re.MULTILINE)

    for i, (type_id, file_id) in enumerate(headers):
        if type_id != '1001':  # PrefabInstance
            continue
        if i + 1 >= len(blocks):
            continue
        block = blocks[i + 1]

        # Find GUID
        guid_match = re.search(r'guid:\s*([a-f0-9]+)', block)
        if not guid_match:
            continue
        guid = guid_match.group(1)

        if guid not in (OBSTACLE_GUID, THUMP1_GUID, THUMP2_GUID):
            continue

        # Extract position from m_Modifications
        pos = {'x': 0.0, 'y': 0.0, 'z': 0.0}
        scale = {'x': 1.0, 'y': 1.0, 'z': 1.0}

        # Find all property modifications
        mod_pattern = r"propertyPath:\s*m_Local(Position|Scale)\.(x|y|z)\s*\n\s*value:\s*([^\n]+)"
        for match in re.finditer(mod_pattern, block):
            prop_type = match.group(1).lower()  # position or scale
            axis = match.group(2)
            value = float(match.group(3))
            if prop_type == 'position':
                pos[axis] = value
            else:
                scale[axis] = value

        if guid == OBSTACLE_GUID:
            obstacles.append({'pos': pos, 'scale': scale})
        elif guid == THUMP1_GUID:
            thumps.append({'pos': pos, 'type': 1})
        elif guid == THUMP2_GUID:
            thumps.append({'pos': pos, 'type': 2})

    return obstacles, thumps


def parse_game_objects(content):
    """Extract tagged GameObjects (BallReflectors, Balls/Spheres) with their transforms."""
    ball_reflectors = []
    balls = []

    blocks = re.split(r'^--- !u!\d+ &\d+', content, flags=re.MULTILINE)
    headers = re.findall(r'^--- !u!(\d+) &(\d+)', content, flags=re.MULTILINE)

    # Build file_id -> block map
    block_map = {}
    for i, (type_id, file_id) in enumerate(headers):
        if i + 1 < len(blocks):
            block_map[file_id] = (type_id, blocks[i + 1])

    # Find GameObjects with relevant tags/names
    tagged_objects = {}  # file_id -> tag
    for file_id, (type_id, block) in block_map.items():
        if type_id != '1':  # GameObject
            continue
        tag_match = re.search(r'm_TagString:\s*(\S+)', block)
        name_match = re.search(r'm_Name:\s*(.+)', block)
        tag = tag_match.group(1) if tag_match else ''
        name = name_match.group(1).strip() if name_match else ''

        if tag in ('BallReflector',) or 'Cube' in name:
            tagged_objects[file_id] = 'reflector'
        elif 'Sphere' in name:
            tagged_objects[file_id] = 'ball'

    # Find Transforms that reference these GameObjects
    for file_id, (type_id, block) in block_map.items():
        if type_id != '4':  # Transform
            continue
        go_match = re.search(r'm_GameObject:\s*\{fileID:\s*(\d+)', block)
        if not go_match:
            continue
        go_id = go_match.group(1)
        if go_id not in tagged_objects:
            continue

        # Extract position
        pos_match = re.search(
            r'm_LocalPosition:\s*\{x:\s*([^,]+),\s*y:\s*([^,]+),\s*z:\s*([^}]+)\}',
            block
        )
        scale_match = re.search(
            r'm_LocalScale:\s*\{x:\s*([^,]+),\s*y:\s*([^,]+),\s*z:\s*([^}]+)\}',
            block
        )

        if not pos_match:
            continue

        pos = {
            'x': float(pos_match.group(1)),
            'y': float(pos_match.group(2)),
            'z': float(pos_match.group(3)),
        }
        scale = {'x': 1, 'y': 1, 'z': 1}
        if scale_match:
            scale = {
                'x': float(scale_match.group(1)),
                'y': float(scale_match.group(2)),
                'z': float(scale_match.group(3)),
            }

        obj_type = tagged_objects[go_id]
        if obj_type == 'reflector':
            ball_reflectors.append({'pos': pos, 'scale': scale})
        else:
            balls.append({'pos': pos, 'scale': scale})

    return ball_reflectors, balls


def fmt(v):
    """Format a float, removing trailing zeros."""
    if v == int(v):
        return str(int(v))
    return f"{v:.4g}"


def generate_godot_level(level_num, obstacles, thumps, ball_reflectors, balls):
    end_goal_z = LEVEL_END_GOALS[level_num]
    end_trigger_z = LEVEL_END_TRIGGERS[level_num]

    ext_resources = []
    ext_id = 1

    def add_ext(type_name, path):
        nonlocal ext_id
        ext_resources.append(f'[ext_resource type="{type_name}" path="{path}" id="{ext_id}"]')
        rid = ext_id
        ext_id += 1
        return rid

    player_id = add_ext("PackedScene", "res://prefabs/player.tscn")
    end_goal_id = add_ext("PackedScene", "res://prefabs/end_goal.tscn")
    end_trigger_id = add_ext("PackedScene", "res://prefabs/end_trigger.tscn")
    camera_id = add_ext("Script", "res://scripts/follow_camera.gd")
    score_id = add_ext("Script", "res://scripts/score.gd")
    pause_id = add_ext("Script", "res://scripts/pause_menu.gd")
    lc_id = add_ext("Script", "res://scripts/level_complete_ui.gd")

    obstacle_id = add_ext("PackedScene", "res://prefabs/obstacle.tscn") if obstacles else None
    thump_id = add_ext("PackedScene", "res://prefabs/thump.tscn") if thumps else None
    reflector_id = add_ext("PackedScene", "res://prefabs/ball_reflector.tscn") if ball_reflectors else None
    ball_id = add_ext("PackedScene", "res://prefabs/ball.tscn") if balls else None

    L = []
    w = L.append

    w(f'[gd_scene load_steps={ext_id + 6} format=3]')
    w('')
    for er in ext_resources:
        w(er)
    w('')

    # Sub-resources
    w('[sub_resource type="BoxMesh" id="ground_mesh"]')
    w('size = Vector3(15, 1, 10000)')
    w('')
    w('[sub_resource type="StandardMaterial3D" id="ground_mat"]')
    w('albedo_color = Color(1, 1, 1, 1)')
    w('')
    w('[sub_resource type="BoxShape3D" id="ground_shape"]')
    w('size = Vector3(15, 1, 10000)')
    w('')
    w('[sub_resource type="Environment" id="env"]')
    w('background_mode = 1')
    w('background_color = Color(0.784, 0.784, 0.784, 1)')
    w('fog_enabled = true')
    w('fog_light_color = Color(0.784, 0.784, 0.784, 1)')
    w('fog_density = 0.005')
    w('')
    w('[sub_resource type="LabelSettings" id="score_ls"]')
    w('font_size = 32')
    w('font_color = Color(0.1, 0.1, 0.1, 1)')
    w('')
    w('[sub_resource type="LabelSettings" id="lc_ls"]')
    w('font_size = 48')
    w('font_color = Color(0.1, 0.1, 0.1, 1)')
    w('')

    # Nodes
    w(f'[node name="Level{level_num:02d}" type="Node3D"]')
    w('')
    w('[node name="WorldEnvironment" type="WorldEnvironment" parent="."]')
    w('environment = SubResource("env")')
    w('')
    w('[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]')
    w('transform = Transform3D(1, 0, 0, 0, 0.707, 0.707, 0, -0.707, 0.707, 0, 10, 10)')
    w('')
    w('[node name="Ground" type="StaticBody3D" parent="."]')
    w('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, -4980)')
    w('')
    w('[node name="MeshInstance3D" type="MeshInstance3D" parent="Ground"]')
    w('mesh = SubResource("ground_mesh")')
    w('material_override = SubResource("ground_mat")')
    w('')
    w('[node name="CollisionShape3D" type="CollisionShape3D" parent="Ground"]')
    w('shape = SubResource("ground_shape")')
    w('')
    w(f'[node name="Player" parent="." instance=ExtResource("{player_id}")]')
    w('transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)')
    w('')
    w('[node name="Camera3D" type="Camera3D" parent="."]')
    w(f'script = ExtResource("{camera_id}")')
    w('target = NodePath("../Player")')
    w('offset = Vector3(0, 3, 8)')
    w('')
    w(f'[node name="EndGoal" parent="." instance=ExtResource("{end_goal_id}")]')
    w(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, {-end_goal_z})')
    w('')
    w(f'[node name="EndTrigger" parent="." instance=ExtResource("{end_trigger_id}")]')
    w(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, {-end_trigger_z})')
    w('')

    # HUD
    w('[node name="HUD" type="CanvasLayer" parent="."]')
    w('')
    w('[node name="ScoreLabel" type="Label" parent="HUD"]')
    w('anchors_preset = 0')
    w('offset_left = 20.0')
    w('offset_top = 20.0')
    w('offset_right = 200.0')
    w('offset_bottom = 60.0')
    w('text = "0%"')
    w('label_settings = SubResource("score_ls")')
    w(f'script = ExtResource("{score_id}")')
    w('player_path = NodePath("../../Player")')
    w(f'end_trigger_z = {float(-end_trigger_z)}')
    w('')

    # Level Complete UI
    w('[node name="LevelCompleteUI" type="Control" parent="HUD"]')
    w('layout_mode = 1')
    w('anchors_preset = 15')
    w('anchor_right = 1.0')
    w('anchor_bottom = 1.0')
    w(f'script = ExtResource("{lc_id}")')
    w('')
    w('[node name="Panel" type="Panel" parent="HUD/LevelCompleteUI"]')
    w('layout_mode = 1')
    w('anchors_preset = 8')
    w('anchor_left = 0.5')
    w('anchor_top = 0.5')
    w('anchor_right = 0.5')
    w('anchor_bottom = 0.5')
    w('offset_left = -150.0')
    w('offset_top = -80.0')
    w('offset_right = 150.0')
    w('offset_bottom = 80.0')
    w('grow_horizontal = 2')
    w('grow_vertical = 2')
    w('')
    w('[node name="VBox" type="VBoxContainer" parent="HUD/LevelCompleteUI/Panel"]')
    w('layout_mode = 1')
    w('anchors_preset = 15')
    w('anchor_right = 1.0')
    w('anchor_bottom = 1.0')
    w('offset_left = 10.0')
    w('offset_top = 10.0')
    w('offset_right = -10.0')
    w('offset_bottom = -10.0')
    w('theme_override_constants/separation = 15')
    w('')
    w('[node name="Label" type="Label" parent="HUD/LevelCompleteUI/Panel/VBox"]')
    w('layout_mode = 2')
    w('text = "Level Complete!"')
    w('label_settings = SubResource("lc_ls")')
    w('horizontal_alignment = 1')
    w('')
    w('[node name="NextLevelButton" type="Button" parent="HUD/LevelCompleteUI/Panel/VBox"]')
    w('layout_mode = 2')
    w('text = "Next Level"')
    w('')

    # Pause Menu
    w('[node name="PauseMenu" type="Control" parent="HUD"]')
    w('layout_mode = 1')
    w('anchors_preset = 15')
    w('anchor_right = 1.0')
    w('anchor_bottom = 1.0')
    w(f'script = ExtResource("{pause_id}")')
    w('')
    w('[node name="PausePanel" type="Panel" parent="HUD/PauseMenu"]')
    w('layout_mode = 1')
    w('anchors_preset = 8')
    w('anchor_left = 0.5')
    w('anchor_top = 0.5')
    w('anchor_right = 0.5')
    w('anchor_bottom = 0.5')
    w('offset_left = -120.0')
    w('offset_top = -100.0')
    w('offset_right = 120.0')
    w('offset_bottom = 100.0')
    w('grow_horizontal = 2')
    w('grow_vertical = 2')
    w('')
    w('[node name="VBox" type="VBoxContainer" parent="HUD/PauseMenu/PausePanel"]')
    w('layout_mode = 1')
    w('anchors_preset = 15')
    w('anchor_right = 1.0')
    w('anchor_bottom = 1.0')
    w('offset_left = 10.0')
    w('offset_top = 10.0')
    w('offset_right = -10.0')
    w('offset_bottom = -10.0')
    w('theme_override_constants/separation = 10')
    w('')
    w('[node name="PausedLabel" type="Label" parent="HUD/PauseMenu/PausePanel/VBox"]')
    w('layout_mode = 2')
    w('text = "Paused"')
    w('horizontal_alignment = 1')
    w('')
    w('[node name="ResumeButton" type="Button" parent="HUD/PauseMenu/PausePanel/VBox"]')
    w('layout_mode = 2')
    w('text = "Resume"')
    w('')
    w('[node name="RestartButton" type="Button" parent="HUD/PauseMenu/PausePanel/VBox"]')
    w('layout_mode = 2')
    w('text = "Restart"')
    w('')
    w('[node name="MainMenuButton" type="Button" parent="HUD/PauseMenu/PausePanel/VBox"]')
    w('layout_mode = 2')
    w('text = "Main Menu"')
    w('')

    # Place obstacles
    for i, obs in enumerate(obstacles):
        x, y, z = obs['pos']['x'], obs['pos']['y'], -obs['pos']['z']
        sx, sy, sz = obs['scale']['x'], obs['scale']['y'], obs['scale']['z']
        w(f'[node name="Obstacle{i+1}" parent="." instance=ExtResource("{obstacle_id}")]')
        w(f'transform = Transform3D({fmt(sx)}, 0, 0, 0, {fmt(sy)}, 0, 0, 0, {fmt(sz)}, {fmt(x)}, {fmt(y)}, {fmt(z)})')
        w('')

    # Place thumps
    for i, t in enumerate(thumps):
        x, y, z = t['pos']['x'], t['pos']['y'], -t['pos']['z']
        w(f'[node name="Thump{t["type"]}_{i+1}" parent="." instance=ExtResource("{thump_id}")]')
        w(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {fmt(x)}, {fmt(y)}, {fmt(z)})')
        w(f'thump_type = {t["type"]}')
        w('')

    # Place ball reflectors
    for i, br in enumerate(ball_reflectors):
        x, y, z = br['pos']['x'], br['pos']['y'], -br['pos']['z']
        w(f'[node name="BallReflector{i+1}" parent="." instance=ExtResource("{reflector_id}")]')
        w(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {fmt(x)}, {fmt(y)}, {fmt(z)})')
        w('')

    # Place balls
    for i, ball in enumerate(balls):
        x, y, z = ball['pos']['x'], ball['pos']['y'], -ball['pos']['z']
        w(f'[node name="Ball{i+1}" parent="." instance=ExtResource("{ball_id}")]')
        w(f'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {fmt(x)}, {fmt(y)}, {fmt(z)})')
        w('')

    # Connections
    w('[connection signal="pressed" from="HUD/LevelCompleteUI/Panel/VBox/NextLevelButton" to="HUD/LevelCompleteUI" method="_on_next_level_pressed"]')
    w('[connection signal="pressed" from="HUD/PauseMenu/PausePanel/VBox/ResumeButton" to="HUD/PauseMenu" method="_on_resume_pressed"]')
    w('[connection signal="pressed" from="HUD/PauseMenu/PausePanel/VBox/RestartButton" to="HUD/PauseMenu" method="_on_restart_pressed"]')
    w('[connection signal="pressed" from="HUD/PauseMenu/PausePanel/VBox/MainMenuButton" to="HUD/PauseMenu" method="_on_main_menu_pressed"]')

    return '\n'.join(L) + '\n'


def main():
    os.makedirs(GODOT_DIR, exist_ok=True)

    for level_num in range(1, 16):
        unity_file = UNITY_DIR / f"Level{level_num:02d}.unity"
        if not unity_file.exists():
            print(f"Warning: {unity_file} not found")
            continue

        print(f"Processing Level {level_num:02d}...")
        with open(unity_file, 'r') as f:
            content = f.read()

        obstacles, thumps = parse_prefab_instances(content)
        ball_reflectors, balls = parse_game_objects(content)

        print(f"  Obstacles: {len(obstacles)}, Thumps: {len(thumps)}, "
              f"Reflectors: {len(ball_reflectors)}, Balls: {len(balls)}")

        scene = generate_godot_level(level_num, obstacles, thumps, ball_reflectors, balls)

        output_file = GODOT_DIR / f"level_{level_num:02d}.tscn"
        with open(output_file, 'w') as f:
            f.write(scene)
        print(f"  -> {output_file}")

    print("\nDone!")


if __name__ == '__main__':
    main()
