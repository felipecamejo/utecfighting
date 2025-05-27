extends CharacterBody2D

const VELOCIDAD := 40
const Y_MIN := 255
const Y_MAX := 265
const X_MIN := 32
const X_MAX := 400

func _ready() -> void:
	$AnimatedSprite2D.play("PlayerIdle")
	$AnimatedSprite2D.global_position.x = 216
	$AnimatedSprite2D.global_position.y = 190

func _process(delta: float) -> void:
	var animation = "PlayerIdle"
	var movimiento := Vector2.ZERO

	# Movimiento vertical
	if Input.is_action_pressed("mover_arriba"):
		movimiento.y -= 1
	elif Input.is_action_pressed("mover_abajo"):
		movimiento.y += 1

	# Movimiento horizontal
	if Input.is_action_pressed("mover_izquierda"):  # tecla A
		movimiento.x -= 2
	elif Input.is_action_pressed("mover_derecha"):  # tecla D
		movimiento.x += 2

	# Aplicar movimiento
	var nueva_pos := global_position + movimiento * VELOCIDAD * delta
	nueva_pos.y = clamp(nueva_pos.y, Y_MIN, Y_MAX)
	nueva_pos.x = clamp(nueva_pos.x, X_MIN, X_MAX)
	global_position = nueva_pos

	# Voltear sprite según dirección horizontal
	$AnimatedSprite2D.flip_h = global_position.x < 216

	# Animaciones
	if Input.is_action_pressed("Guard"):
		animation = "PlayerGuard"
	elif Input.is_action_pressed("Punch"):
		animation = "PlayerPunch"
	elif movimiento.length() > 0:
		animation = "PlayerWalk"
	elif movimiento.length() == 0 and (global_position.x < 190 or global_position.x > 242):
		animation = "PlayerWalk"
	else:
		animation = "PlayerIdle"

	# Cambiar animación si es distinta
	if $AnimatedSprite2D.animation != animation:
		$AnimatedSprite2D.play(animation)
