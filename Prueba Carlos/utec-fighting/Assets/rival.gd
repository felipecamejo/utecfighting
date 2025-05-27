extends CharacterBody2D

const VELOCIDAD := 40
const Y_MIN := 255
const Y_MAX := 265
const X_MIN := 32
const X_MAX := 400
const ESCALA_NORMAL := Vector2(2.7, 2.7)
const ESCALA_AGRANDADO := Vector2(3, 3)

func _ready() -> void:
	$AnimatedSprite2D.play("RivalIdle")
	$AnimatedSprite2D.global_position.x = 216
	$AnimatedSprite2D.global_position.y = 150

func _process(delta: float) -> void:
	var animation = "RivalIdle"
	var movimiento := Vector2.ZERO

	# Movimiento vertical
	if Input.is_action_pressed("mover_arribaP2"):
		movimiento.y -= 1
	elif Input.is_action_pressed("mover_abajoP2"):
		movimiento.y += 1

	# Movimiento horizontal
	if Input.is_action_pressed("mover_izquierdaP2"):  # tecla A
		movimiento.x -= 2
	elif Input.is_action_pressed("mover_derechaP2"):  # tecla D
		movimiento.x += 2

	# Aplicar movimiento
	var nueva_pos := global_position + movimiento * VELOCIDAD * delta
	nueva_pos.y = clamp(nueva_pos.y, Y_MIN, Y_MAX)
	nueva_pos.x = clamp(nueva_pos.x, X_MIN, X_MAX)
	global_position = nueva_pos

	# Escalar suavemente entre Y_MIN (escala normal) y Y_MAX (escala agrandada)
	var factor: float = clamp((global_position.y - Y_MIN) / float(Y_MAX - Y_MIN), 0.0, 1.0)
	var escala_objetivo := ESCALA_NORMAL.lerp(ESCALA_AGRANDADO, factor)
	$AnimatedSprite2D.scale = $AnimatedSprite2D.scale.lerp(escala_objetivo, 0.1)


	$AnimatedSprite2D.scale = $AnimatedSprite2D.scale.lerp(escala_objetivo, 0.1)


	# Voltear sprite según dirección horizontal
	$AnimatedSprite2D.flip_h = global_position.x < 216

	# Animaciones
	if Input.is_action_pressed("GuardP2"):
		animation = "RivalGuard"
	elif Input.is_action_pressed("PunchP2"):
		animation = "RivalPunch"
	elif movimiento.length() > 0:
		animation = "RivalIdle"
	elif movimiento.length() == 0 and (global_position.x < 190 or global_position.x > 242):
		animation = "RivalIdle"
	else:
		animation = "RivalIdle"

	# Cambiar animación si es distinta
	if $AnimatedSprite2D.animation != animation:
		$AnimatedSprite2D.play(animation)
