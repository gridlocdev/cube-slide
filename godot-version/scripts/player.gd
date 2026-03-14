extends RigidBody3D

@export var forward_force := 4000.0
@export var sideways_force := 125.0

var has_collided := false
var movement_enabled := true

@onready var hit_sound: AudioStreamPlayer3D = $HitSound

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

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
