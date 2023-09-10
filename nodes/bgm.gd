extends AudioStreamPlayer

const TITLE_TRACK = "title"
const GAME_TRACK = "game"

var current_track = ""


func _ready():
	volume_db = -7


func play_title_music():
	if current_track != TITLE_TRACK:
		stream = load("res://assets/music/title_music.ogg")
		play()
		current_track = TITLE_TRACK


func play_game_music():
	if current_track != GAME_TRACK:
		stream = load("res://assets/music/game_music.ogg")
		play()
		current_track = GAME_TRACK
