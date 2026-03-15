extends Control

var menu_click_stream := preload("res://audio/menuClick.wav")
var controls_overlay_scene := preload("res://scenes/controls_overlay.tscn")
var bold_font := preload("res://fonts/Roboto-Bold.ttf")
var controls_overlay: Control

const COLOR_WHITE := Color(1, 1, 1, 1)
const COLOR_RED := Color(0.7, 0.2, 0.2, 1)
const COLOR_SHADOW := Color(0, 0, 0, 0.4)
const SHADOW_OFFSET := Vector2(2, 2)
const HOVER_DURATION := 0.15

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_add_controls_overlay()

func _build_ui() -> void:
	# Remove the existing PausePanel
	for child in get_children():
		child.queue_free()

	# Dim background
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.3)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	# Center container
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 40)
	center.add_child(vbox)

	# "PAUSED" title
	var title := Label.new()
	title.text = "PAUSED"
	title.add_theme_font_override("font", bold_font)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_shadow_color", COLOR_SHADOW)
	title.add_theme_constant_override("shadow_offset_x", int(SHADOW_OFFSET.x))
	title.add_theme_constant_override("shadow_offset_y", int(SHADOW_OFFSET.y))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Menu items
	_add_menu_item(vbox, "RESUME", _on_resume_pressed)
	_add_menu_item(vbox, "RESTART", _on_restart_pressed)
	_add_menu_item(vbox, "CONTROLS", _on_controls_pressed)
	_add_menu_item(vbox, "MENU", _on_main_menu_pressed)

func _add_menu_item(parent: VBoxContainer, text: String, callback: Callable) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", bold_font)
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", COLOR_WHITE)
	label.add_theme_color_override("font_shadow_color", COLOR_SHADOW)
	label.add_theme_constant_override("shadow_offset_x", int(SHADOW_OFFSET.x))
	label.add_theme_constant_override("shadow_offset_y", int(SHADOW_OFFSET.y))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(label)

	label.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			callback.call()
	)
	label.mouse_entered.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(label, "theme_override_colors/font_color", COLOR_RED, HOVER_DURATION)
	)
	label.mouse_exited.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(label, "theme_override_colors/font_color", COLOR_WHITE, HOVER_DURATION)
	)

func _add_controls_overlay() -> void:
	controls_overlay = controls_overlay_scene.instantiate()
	controls_overlay.closed.connect(_on_controls_closed)
	add_child(controls_overlay)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if controls_overlay.visible:
			return
		if visible:
			resume()
		else:
			pause()

func pause() -> void:
	if GameManager.game_has_ended:
		return
	visible = true
	get_tree().paused = true

func resume() -> void:
	visible = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	_click()
	resume()

func _on_restart_pressed() -> void:
	_click()
	resume()
	GameManager._restart()

func _on_main_menu_pressed() -> void:
	_click()
	resume()
	GameManager.load_main_menu()

func _on_controls_pressed() -> void:
	_click()
	controls_overlay.show_controls()

func _on_controls_closed() -> void:
	pass

func _click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = menu_click_stream
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
