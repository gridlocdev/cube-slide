extends Control

func _ready() -> void:
	MusicManager.play_title_music()

func _on_exit_pressed() -> void:
	if OS.has_feature("web"):
		GameManager.load_main_menu()
	else:
		get_tree().quit()

func _on_bonus_pressed() -> void:
	GameManager.load_next_level()
