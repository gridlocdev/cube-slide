extends Control

var _thin_font := preload("res://fonts/Roboto-Thin.ttf")
var _bold_font := preload("res://fonts/Roboto-Bold.ttf")

func _ready() -> void:
	visible = false
	add_to_group("level_complete_ui")

func start_sequence() -> void:
	if visible:
		return
	visible = true

	# Remove old scene children (Panel/VBox/etc from .tscn)
	for child in get_children():
		child.queue_free()

	# White overlay (full screen)
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(PRESET_FULL_RECT)
	overlay.color = Color(1, 1, 1, 0)
	add_child(overlay)

	# Determine level number from scene path
	var scene_path := get_tree().current_scene.scene_file_path
	var level_num := _extract_level_number(scene_path)

	# "LEVEL X" — thin, large, centered slightly above middle
	var level_label := Label.new()
	level_label.text = "LEVEL %d" % level_num
	level_label.add_theme_font_override("font", _thin_font)
	level_label.add_theme_font_size_override("font_size", 100)
	level_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 0))
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.set_anchors_preset(PRESET_CENTER)
	level_label.offset_left = -400
	level_label.offset_right = 400
	level_label.offset_top = -100
	level_label.offset_bottom = 0
	add_child(level_label)

	# "COMPLETE" — bold, smaller, just below
	var complete_label := Label.new()
	complete_label.text = "COMPLETE"
	complete_label.add_theme_font_override("font", _bold_font)
	complete_label.add_theme_font_size_override("font_size", 60)
	complete_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 0))
	complete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	complete_label.set_anchors_preset(PRESET_CENTER)
	complete_label.offset_left = -400
	complete_label.offset_right = 400
	complete_label.offset_top = 0
	complete_label.offset_bottom = 80
	add_child(complete_label)

	# Animation sequence
	var tween := create_tween()
	# 1. Fade to white
	tween.tween_property(overlay, "color:a", 1.0, 0.8)
	# 2. Fade in text
	tween.tween_property(level_label, "theme_override_colors/font_color:a", 1.0, 0.6)
	tween.parallel().tween_property(complete_label, "theme_override_colors/font_color:a", 1.0, 0.6)
	# 3. Hold, then advance
	tween.tween_interval(2.0)
	tween.tween_callback(GameManager.load_next_level)

func _extract_level_number(path: String) -> int:
	var regex := RegEx.new()
	regex.compile("level_(\\d+)")
	var result := regex.search(path)
	if result:
		return result.get_string(1).to_int()
	return 0

# Stub for legacy button connection in .tscn files
func _on_next_level_pressed() -> void:
	pass
