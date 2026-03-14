extends RigidBody3D

@export var jump_height := 15
@export var thump_type := 1  # 1 or 2

var _frame_count := 0
var _thump_beat := true

func _ready() -> void:
	_jump()
	_thump_beat = !_thump_beat

func _physics_process(_delta: float) -> void:
	_frame_count += 1
	if _frame_count % 184 == 0:
		_jump()
		_thump_beat = !_thump_beat

func _jump() -> void:
	if _thump_beat:
		if thump_type == 1:
			linear_velocity = Vector3(0, jump_height, 0)
	else:
		if thump_type == 2:
			linear_velocity = Vector3(0, jump_height, 0)
