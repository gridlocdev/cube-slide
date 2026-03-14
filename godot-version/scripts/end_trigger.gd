extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var player := body as RigidBody3D
		if player.has_method("disable_movement"):
			player.disable_movement()
		# Find HUD and start level complete sequence
		var hud := get_tree().get_first_node_in_group("level_complete_ui")
		if hud and not player.has_collided:
			hud.start_sequence()
