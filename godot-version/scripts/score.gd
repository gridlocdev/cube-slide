extends Label

@export var player_path: NodePath
@export var end_trigger_z: float = -500.0

var _player: Node3D

func _ready() -> void:
	_player = get_node(player_path)
	text = "0%"

func _process(_delta: float) -> void:
	if not _player:
		return
	var player_z: float = _player.global_position.z
	# Unity Z+ forward, Godot Z- forward
	# Progress = how far player has gone toward end_trigger_z (negative)
	var progress := (player_z / end_trigger_z) * 100.0
	if progress > 100.0:
		text = "100%"
	else:
		text = "%d%%" % int(progress)
