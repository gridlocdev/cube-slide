extends Control

func _ready() -> void:
	MusicManager.play_title_music()
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)

func _on_menu_pressed() -> void:
	GameManager.load_main_menu()

func _on_bonus_pressed() -> void:
	GameManager.load_next_level()
