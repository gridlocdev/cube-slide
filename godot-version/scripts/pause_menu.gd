extends Control

var menu_click_stream := preload("res://audio/menuClick.wav")

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			resume()
		else:
			pause()

func pause() -> void:
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

func _click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = menu_click_stream
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
