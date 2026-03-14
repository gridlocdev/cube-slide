extends CharacterBody3D

@export var speed := 10.0
@export var lateral_speed := 8.0
@export var gravity := 30.0

var start_z: float
var goal_z: float
var finished := false

@onready var hud_label: Label = %HUDLabel
@onready var goal_area: Area3D = %GoalArea

func _ready() -> void:
	start_z = global_position.z
	goal_area.body_entered.connect(_on_goal_reached)

func _physics_process(delta: float) -> void:
	if finished:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Lateral movement
	var lateral := 0.0
	if Input.is_key_pressed(KEY_A):
		lateral -= lateral_speed
	if Input.is_key_pressed(KEY_D):
		lateral += lateral_speed
	velocity.x = lateral
	velocity.z = -speed

	move_and_slide()

	# Fall off platform — respawn at start
	if global_position.y < -10.0:
		global_position = Vector3(0, 0.5, start_z)
		velocity = Vector3.ZERO
		return

	var progress := clampf((start_z - global_position.z) / (start_z - goal_z), 0.0, 1.0)
	hud_label.text = "%d%%" % int(progress * 100)

func _on_goal_reached(_body: Node3D) -> void:
	if _body != self:
		return
	finished = true
	velocity = Vector3.ZERO
	hud_label.text = "Level Complete!"
