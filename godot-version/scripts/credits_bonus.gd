extends Control

func _ready() -> void:
	MusicManager.play_title_music()

func _on_menu_pressed() -> void:
	GameManager.load_main_menu()
