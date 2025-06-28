extends Control

@export var video: VideoStream
@export var siguiente_escena: String

@onready var player: VideoStreamPlayer = $VideoPlayer

func _ready():
	player.stream = video
	player.visible = true
	player.play()
	player.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file(siguiente_escena)
