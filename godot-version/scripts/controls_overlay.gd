extends Control

signal closed

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_controls() -> void:
	visible = true

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_close()

func _on_close_pressed() -> void:
	_close()

func _close() -> void:
	visible = false
	closed.emit()
