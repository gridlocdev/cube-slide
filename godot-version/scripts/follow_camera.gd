extends Camera3D

@export var target: NodePath
@export var offset := Vector3(0, 1.2, 5)

var _target_node: Node3D

func _ready() -> void:
	_target_node = get_node(target)
	fov = 60.0
	# Point camera straight forward (along -Z), not at the player
	rotation_degrees = Vector3(0, 0, 0)

func _process(_delta: float) -> void:
	if _target_node:
		global_position = _target_node.global_position + offset
