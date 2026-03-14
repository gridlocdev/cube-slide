extends Control

func _ready() -> void:
	MusicManager.play_title_music()

func _load_level(num: int) -> void:
	_click()
	GameManager.load_scene("res://scenes/levels/level_%02d.tscn" % num)

func _on_back_pressed() -> void:
	_click()
	GameManager.load_main_menu()

func _click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load("res://audio/menuClick.wav")
	add_child(player)
	player.play()
