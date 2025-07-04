extends Node2D

@onready var enemigo = $soto
@onready var jugador = $personaje

func _ready():
	enemigo.game_over_triggered.connect(_on_soto_game_over_triggered)
	jugador.game_over_triggered.connect(_on_personaje_game_over_triggered)
	
	if Global.dificultad == "facil":
		$soto.vida = 50
	elif Global.dificultad == "dificil":
		$soto.vida = 100

func _on_soto_game_over_triggered() -> void:
	print("¡Ganaste el nivel!")
	cargar_cinematica("res://assets/videos/VideoGanarMejorado.ogv", "res://main_menu.tscn")


func _on_personaje_game_over_triggered() -> void:
	print("¡Perdiste el nivel!")
	cargar_cinematica("res://assets/videos/VideoPerder.ogv", "res://main_menu.tscn")
	
func cargar_cinematica(ruta_video: String, siguiente: String):
	await get_tree().create_timer(7.0).timeout
	var cine = load("res://cinematica.tscn").instantiate()
	cine.video = load(ruta_video)
	cine.siguiente_escena = siguiente
	get_tree().root.add_child(cine)
	queue_free()  # Cerrás el nivel actual
