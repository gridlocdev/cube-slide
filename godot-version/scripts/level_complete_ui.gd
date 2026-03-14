extends Control

func _ready() -> void:
	visible = false
	add_to_group("level_complete_ui")

func _on_next_level_pressed() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load("res://audio/menuClick.wav")
	add_child(player)
	player.play()
	GameManager.load_next_level()
