extends Node

const TIME_TO_MOVE = 0.5

@onready var tutorial_points = [
	$TutorialPoints/Point0, $TutorialPoints/Point1, $TutorialPoints/Point2, $TutorialPoints/Point3, $TutorialPoints/Point4, $TutorialPoints/Point5
]

@onready var tutorial_cam = $TutorialCam
@onready var tutorial_text: Label = $"%TutorialText"
@onready var swish_audio = $SwishAudio

var point_idx = 0
var moving = false


func _ready():
	Bgm.play_title_music()
	_set_tutorial_point(0)

func _process(_delta):
	if Input.is_action_just_pressed("interact") and not moving:
		_progress_tutorial()


func _progress_tutorial():
	if point_idx < len(tutorial_points) - 1:
		_set_tutorial_point(point_idx + 1)
	else:
		SceneManager.switch_to_title()


func _set_tutorial_point(idx: int):
	moving = true
	
	tutorial_points[point_idx].exit()
	
	point_idx = idx
	
	var target = tutorial_points[point_idx]
	target.enter()
	tutorial_text.text = target.description
	
	swish_audio.play()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(tutorial_cam, "global_position", target.global_position, TIME_TO_MOVE)
	var rotation_target = Vector3(0, tutorial_cam.global_rotation.y + wrapf(target.global_rotation.y - tutorial_cam.global_rotation.y, -PI, PI), 0)
	tween.parallel().tween_property(tutorial_cam, "global_rotation", rotation_target, TIME_TO_MOVE)
	
	tween.tween_callback(self.set.bind("moving", false))
