extends RigidBody3D

@export var forward_force := 2000.0
@export var sideways_force := 125.0

const ACTIVATION_DISTANCE := 100.0

var has_collided := false
var movement_enabled := true
var _rigid_bodies: Array[RigidBody3D] = []

@onready var hit_sound: AudioStreamPlayer3D = $HitSound

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	# Collect non-player RigidBody3D obstacle nodes and freeze them
	# (thumps manage their own freeze state for animation)
	for node in get_tree().get_nodes_in_group("obstacle"):
		if node is RigidBody3D and not node.is_in_group("ball"):
			node.freeze = true
			_rigid_bodies.append(node)

func _physics_process(delta: float) -> void:
	if not movement_enabled:
		return

	# Forward force (Unity Z+ = Godot Z-)
	apply_central_force(Vector3(0, 0, -forward_force * delta))

	# Sideways movement (VelocityChange in Unity = impulse ignoring mass)
	if Input.is_action_pressed("move_right"):
		apply_central_impulse(Vector3(sideways_force * delta, 0, 0))
	elif Input.is_action_pressed("move_left"):
		apply_central_impulse(Vector3(-sideways_force * delta, 0, 0))

	# Fall death
	if global_position.y < -2.0:
		GameManager.end_game()

	# Activate/deactivate distant physics bodies
	var pz := global_position.z
	for body in _rigid_bodies:
		var dist := absf(body.global_position.z - pz)
		body.freeze = dist > ACTIVATION_DISTANCE

func _on_body_entered(body: Node) -> void:
	if not movement_enabled:
		return
	if body.is_in_group("obstacle") or body.is_in_group("thump") or body.is_in_group("ball_reflector"):
		hit_sound.play()
		movement_enabled = false
		has_collided = true
		GameManager.end_game()

func disable_movement() -> void:
	movement_enabled = false
