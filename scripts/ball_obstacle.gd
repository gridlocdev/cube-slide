extends RigidBody3D

@export var sideways_force := 10.0

var _initial_push := true

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if _initial_push:
		_initial_push = false
		linear_velocity = Vector3(-sideways_force, -10, 0)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball_reflector"):
		if body.global_position.x > global_position.x:
			linear_velocity = Vector3(-sideways_force, -10, 0)
		else:
			linear_velocity = Vector3(sideways_force, -10, 0)
