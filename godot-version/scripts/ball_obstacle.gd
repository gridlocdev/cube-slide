extends RigidBody3D

@export var sideways_force := 100.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	# Initial push
	apply_central_impulse(Vector3(-sideways_force * 0.06, -10, 0))

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball_reflector"):
		if body.global_position.x > global_position.x:
			apply_central_impulse(Vector3(-sideways_force * 0.06, -10, 0))
		else:
			apply_central_impulse(Vector3(sideways_force * 0.06, -10, 0))
