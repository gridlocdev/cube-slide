extends Camera3D

@export var target: NodePath
@export var offset := Vector3(0, 3, 8)

var _target_node: Node3D

func _ready() -> void:
	_target_node = get_node(target)

func _process(_delta: float) -> void:
	if _target_node:
		global_position = _target_node.global_position + offset
		look_at(_target_node.global_position, Vector3.UP)
