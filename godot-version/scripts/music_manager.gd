extends Node

var title_player: AudioStreamPlayer
var game_player: AudioStreamPlayer

func _ready() -> void:
	title_player = AudioStreamPlayer.new()
	title_player.stream = load("res://audio/titleScreen.wav")
	title_player.bus = "Master"
	add_child(title_player)

	game_player = AudioStreamPlayer.new()
	game_player.stream = load("res://audio/CubeSlideMusic.wav")
	game_player.bus = "Master"
	add_child(game_player)

func play_title_music() -> void:
	if not title_player.playing:
		game_player.stop()
		title_player.play()

func play_game_music() -> void:
	if not game_player.playing:
		title_player.stop()
		game_player.play()

func stop_all() -> void:
	title_player.stop()
	game_player.stop()
