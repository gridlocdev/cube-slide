extends Label

@export var player_path: NodePath
@export var end_trigger_z: float = -500.0

var _player: Node3D
var _thin_font := preload("res://fonts/Roboto-Thin.ttf")

func _ready() -> void:
	_player = get_node(player_path)
	text = "0%"

	# Restyle: large thin font, top center
	label_settings = null
	add_theme_font_override("font", _thin_font)
	add_theme_font_size_override("font_size", 130)
	add_theme_color_override("font_color", Color(0.35, 0.35, 0.35, 1))
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Reposition to top center
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_left = 0
	offset_top = 160
	offset_right = 0
	offset_bottom = 280

func _process(_delta: float) -> void:
	if not _player:
		return
	var player_z: float = _player.global_position.z
	var progress := (player_z / end_trigger_z) * 100.0
	if progress > 100.0:
		text = "100%"
	else:
		text = "%d%%" % int(progress)
