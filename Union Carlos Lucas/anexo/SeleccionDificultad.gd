extends Control

signal dificultad_seleccionada(nivel: String)

@onready var facil_btn = $VBoxContainer/Facil
@onready var dificil_btn = $VBoxContainer/Dificil

func _ready():
	facil_btn.pressed.connect(func(): _seleccionar("facil"))
	dificil_btn.pressed.connect(func(): _seleccionar("dificil"))

func _seleccionar(nivel: String):
	emit_signal("dificultad_seleccionada", nivel)
	queue_free()
