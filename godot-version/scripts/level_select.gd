extends Control

const COLOR_NORMAL := Color(0.96, 0.96, 0.96, 1)
const COLOR_HOVER := Color(0.90, 0.90, 0.90, 1)
const HOVER_DURATION := 0.15

func _ready() -> void:
	MusicManager.play_title_music()
	for button: Button in get_tree().get_nodes_in_group("") + _get_all_buttons(self):
		pass
	for button: Button in _get_all_buttons(self):
		_setup_hover(button)

func _get_all_buttons(node: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		buttons.append_array(_get_all_buttons(child))
	return buttons

func _setup_hover(button: Button) -> void:
	var font_color: Color = button.get_theme_color("font_color")
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)

	var normal_style: StyleBoxFlat = button.get_theme_stylebox("normal").duplicate()
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", normal_style)

	button.mouse_entered.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(normal_style, "bg_color", COLOR_HOVER, HOVER_DURATION)
	)
	button.mouse_exited.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(normal_style, "bg_color", COLOR_NORMAL, HOVER_DURATION)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back_pressed()

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
