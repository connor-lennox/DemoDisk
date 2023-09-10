extends AudioStreamPlayer

const PLAYING_VOLUME = -7
const OFF_VOLUME = -25
const VOLUME_FADE_TIME = 0.5

const TITLE_TRACK = "title"
const GAME_TRACK = "game"

var current_track = ""

var volume_tween: Tween = null

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

func fade_out():
	if volume_tween:
		volume_tween.kill()
	volume_tween = get_tree().create_tween()
	volume_tween.tween_property(self, "volume_db", OFF_VOLUME, VOLUME_FADE_TIME)

func fade_in():
	if volume_tween:
		volume_tween.kill()
	volume_tween = get_tree().create_tween()
	volume_tween.tween_property(self, "volume_db", PLAYING_VOLUME, VOLUME_FADE_TIME)
