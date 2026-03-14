extends Control

const BUTTON_COLOR_NORMAL := Color(1, 1, 1, 1)
const BUTTON_COLOR_HOVER := Color(0.95, 0.95, 0.95, 1)
const HOVER_DURATION := 0.15

func _ready() -> void:
	MusicManager.play_title_music()
	for button: Button in [%StartButton, %LevelSelectButton]:
		_setup_button_hover(button)

func _setup_button_hover(button: Button) -> void:
	var normal_style: StyleBoxFlat = button.get_theme_stylebox("normal").duplicate()
	button.add_theme_stylebox_override("normal", normal_style)
	# Use the same stylebox for hover so the tween controls the color
	button.add_theme_stylebox_override("hover", normal_style)
	button.mouse_entered.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(normal_style, "bg_color", BUTTON_COLOR_HOVER, HOVER_DURATION)
	)
	button.mouse_exited.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(normal_style, "bg_color", BUTTON_COLOR_NORMAL, HOVER_DURATION)
	)

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
