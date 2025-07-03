extends Control

@export var intro_video: VideoStream
@export var nivel_1_path: String = "res://NivelIsra.tscn"

@onready var video_player: VideoStreamPlayer = $VideoPlayer
@onready var jugar_btn: Button = $VBoxContainer/Jugar
@onready var salir_btn: Button = $VBoxContainer/Salir
@onready var audio_player: AudioStreamPlayer = $MenuMusic

func _ready():
	audio_player.finished.connect(_on_audio_finished)
	#jugar_btn.pressed.connect(_on_jugar_pressed)
	#salir_btn.pressed.connect(_on_salir_pressed)
	#video_player.finished.connect(_on_video_finished)


func _on_jugar_pressed():
	hide_buttons()
	mostrar_seleccion_dificultad()

func _on_salir_pressed():
	get_tree().quit()

func hide_buttons():
	$VBoxContainer.hide()

func play_intro():
	$MenuMusic.stop()
	$ImagenFondo.visible = false
	$ColorRect.visible = false
	$ImagenPersonaje.visible = false
	video_player.stream = intro_video
	video_player.visible = true
	video_player.play()
	
func _on_video_finished():
	print("Cambiando a:", nivel_1_path)
	get_tree().change_scene_to_file(nivel_1_path)
	
func mostrar_seleccion_dificultad():
	var selector = preload("res://SeleccionDificultad.tscn").instantiate()
	add_child(selector)
	
	selector.dificultad_seleccionada.connect(_on_dificultad_elegida)
	
func _on_dificultad_elegida(nivel: String):
	Global.dificultad = nivel
	play_intro()
	
func _on_audio_finished():
	print("Audio terminado. Reiniciando...")
	audio_player.play()  # Vuelve a reproducir
	
