extends Control

func _ready() -> void:
	MusicManager.play_title_music()

func _on_start_pressed() -> void:
	_click()
	GameManager.load_scene("res://scenes/levels/level_01.tscn")

func _on_level_select_pressed() -> void:
	_click()
	GameManager.load_level_select()

func _click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load("res://audio/menuClick.wav")
	add_child(player)
	player.play()
