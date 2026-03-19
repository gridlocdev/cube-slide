extends Node

# Level order matching Unity build index
const LEVELS: Array[String] = [
	"res://scenes/welcome.tscn",      # 0
	"res://scenes/levels/level_01.tscn", # 1
	"res://scenes/levels/level_02.tscn",
	"res://scenes/levels/level_03.tscn",
	"res://scenes/levels/level_04.tscn",
	"res://scenes/levels/level_05.tscn",
	"res://scenes/levels/level_06.tscn",
	"res://scenes/levels/level_07.tscn",
	"res://scenes/levels/level_08.tscn",
	"res://scenes/levels/level_09.tscn",
	"res://scenes/levels/level_10.tscn",
	"res://scenes/levels/level_11.tscn",
	"res://scenes/levels/level_12.tscn", # 12
	"res://scenes/credits.tscn",       # 13
	"res://scenes/levels/level_13.tscn", # 14
	"res://scenes/levels/level_14.tscn", # 15
	"res://scenes/levels/level_15.tscn", # 16
	"res://scenes/credits_bonus.tscn", # 17
	"res://scenes/level_select.tscn",  # 18
]

var game_has_ended := false
var restart_delay := 1.0

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			var value := arg.substr("--scene=".length())
			var path := _resolve_scene(value)
			if path != "":
				call_deferred("_change_scene", path)
				return
			else:
				push_warning("Unknown scene: " + value)

func _resolve_scene(value: String) -> String:
	# Try as a level number (e.g. "5" -> level_05)
	if value.is_valid_int():
		var num := value.to_int()
		var padded := "level_%02d" % num
		for level in LEVELS:
			if padded in level:
				return level
	# Try as a scene name (e.g. "credits", "credits_bonus", "welcome", "level_select")
	for level in LEVELS:
		if value in level:
			return level
	return ""

func end_game() -> void:
	if game_has_ended:
		return
	game_has_ended = true
	get_tree().create_timer(restart_delay).timeout.connect(_restart)

func _restart() -> void:
	game_has_ended = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func load_next_level() -> void:
	var current := get_tree().current_scene.scene_file_path
	for i in LEVELS.size():
		if LEVELS[i] == current and i + 1 < LEVELS.size():
			game_has_ended = false
			_change_scene(LEVELS[i + 1])
			return

func load_scene(path: String) -> void:
	game_has_ended = false
	_change_scene(path)

func load_main_menu() -> void:
	game_has_ended = false
	_change_scene("res://scenes/welcome.tscn")

func load_level_select() -> void:
	game_has_ended = false
	_change_scene("res://scenes/level_select.tscn")

func _change_scene(path: String) -> void:
	if "levels/" in path:
		MusicManager.play_game_music()
	else:
		MusicManager.play_title_music()
	get_tree().change_scene_to_file(path)
