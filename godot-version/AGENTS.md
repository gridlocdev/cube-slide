# CLAUDE.md — Godot 4 3D Best Practices

## Project Structure
- Organize by feature/domain: `scenes/player/`, `scenes/environment/`, `scenes/enemies/`
- Keep meshes, materials, and scripts alongside their scene, not in a flat `assets/` folder
- Use `res://` paths everywhere; never use absolute paths

## 3D Scenes & Nodes
- Root characters with `CharacterBody3D`; use `StaticBody3D` for immovable world geometry
- Use `RigidBody3D` only when full physics simulation is needed
- Use `Area3D` for triggers, damage zones, and detection — not physics bodies
- Attach `CollisionShape3D` as a direct child of physics bodies; never nest it deeper
- Keep `MeshInstance3D` separate from collision — one node for visuals, one for physics
- Name nodes by role: `PlayerMesh`, `HitboxArea`, `CameraArm`

## GDScript 4
- Use `@onready var mesh: MeshInstance3D = $MeshInstance3D` — always annotate types
- Prefer `@export` for tunable values: speeds, distances, curve resources
- Use `class_name` to register scripts as types — avoids scattered `preload()` calls
- Use `signal` with typed parameters: `signal enemy_died(enemy: Enemy)`
- Prefer `move_and_slide()` with `velocity` property over manual collision handling
- Use `await` instead of `yield` for async flows (timers, tweens, signals)
- Use `Callable` and `.connect()` with typed lambdas: `body.entered.connect(_on_body_entered)`

## Camera & Input
- Use `SpringArm3D` as the camera boom — it resolves wall clipping automatically
- Separate camera logic into its own scene/script; never embed it in the player script
- Capture mouse with `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED` on game start
- Use `_unhandled_input()` for 3D camera/player input to avoid consuming UI events
- Define all actions in **Project > Input Map**; never hardcode key literals

## Lighting & Environment
- Use `WorldEnvironment` + `Environment` resource for sky, fog, and tone mapping
- Prefer baked `LightmapGI` for static geometry; use `VoxelGI` for semi-dynamic scenes
- Keep real-time shadow-casting lights to a minimum (≤ 3 per scene for mobile targets)
- Use `DirectionalLight3D` as the primary sun; low-intensity `OmniLight3D` for fill

## Physics
- Set collision layers and masks precisely on every body — never leave all layers enabled
- Use `_physics_process(delta)` for all movement and collision logic, never `_process()`
- Keep collision shapes simple (boxes, capsules, spheres) — avoid `ConcavePolygonShape3D` on dynamic bodies
- Use `RayCast3D` or `ShapeCast3D` nodes for ground detection and ledge checks

## Performance
- Use `MultiMeshInstance3D` for repeated geometry (grass, rocks, debris)
- Cull distant objects with `GeometryInstance3D` visibility range properties
- Use `Node3D.top_level = true` to detach a node from parent transform when needed, instead of re-parenting
- Avoid per-frame `find_child()` or `get_node()` — cache all references with `@onready`
- Merge static environment meshes before import to reduce draw calls
- Prefer `Tween` (created via `create_tween()`) over `AnimationPlayer` for simple procedural motion

## Signals
- Communicate upward via signals, downward via direct method calls
- Never let child nodes store parent references — decouple with signals
- Name signals as past-tense events: `enemy_died`, `checkpoint_reached`
- Disconnect signals when nodes are freed to avoid dangling callables

## Autoloads (Singletons)
- Use sparingly: game state, settings, a global signal bus, save/load manager
- Prefer a signal bus autoload over direct cross-scene node references

## Version Control
- Commit `*.import` files — required for reproducible asset imports
- Add `.godot/` to `.gitignore` (editor cache, not source)
- Store large binary assets (HDRIs, audio, video) in Git LFS or an external CDN
- Pin the exact Godot 4 version in `project.godot` and document it in the README
