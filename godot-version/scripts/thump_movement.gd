extends RigidBody3D

@export var jump_height := 15
@export var thump_type := 1  # 1 or 2

var frame_count := 0
var thump_beat := true

func _ready() -> void:
	_jump()
	thump_beat = !thump_beat

func _physics_process(_delta: float) -> void:
	frame_count += 1
	if frame_count % 270 == 0:
		_jump()
		thump_beat = !thump_beat

func _jump() -> void:
	if thump_beat:
		if thump_type == 1:
			apply_central_impulse(Vector3(0, jump_height, 0))
	else:
		if thump_type == 2:
			apply_central_impulse(Vector3(0, jump_height, 0))
