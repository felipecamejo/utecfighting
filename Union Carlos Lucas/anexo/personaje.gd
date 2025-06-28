extends CharacterBody2D

@export var team: int = 1
@export var movimiento := 200
@export var vida := 100
@export var stamina := 100.0
@export var block_chance := 0.3
@export var attack_cooldown: float = 0.3

#Hud
@onready var barraVida = $"../Hud/PlayerHud/Vida"
@onready var barraStamina = $"../Hud/PlayerHud/Stamina"
@onready var spriteHud = $"../Hud/PlayerHud/AnimatedSprite2D"

var is_attacking := false
var can_attack := true
var recibiendo_golpe := false
signal game_over_triggered #DISPARADOR PARA AVISAR AL CONTRARIO QUE MURIO

func _ready() -> void:
	$PosicionPrincipal.visible = false
	$Golpe/Hitbox.monitoring = false

func _physics_process(_delta):
	actualizar_stamina()
	actualizar_SpriteHud()
	actualizar_vida()
	procesar_movimiento()
	procesar_animacion()
	procesar_ataque()

func actualizar_SpriteHud():
	if vida <= 25:
		spriteHud.frame = 3
	elif vida <= 50:
		spriteHud.frame = 2
	elif vida <= 75:
		spriteHud.frame = 1
	else:
		spriteHud.frame = 0

func actualizar_stamina():
	if stamina < 100 and not is_attacking:
		stamina += 0.1
		if stamina > 100:
			stamina = 100
	barraStamina.value = stamina
	
func actualizar_vida():
	barraVida.value = vida

func procesar_movimiento() -> void:
	var enemigo := get_node_or_null("../soto")
	if enemigo == null:
		enemigo = get_node_or_null("../Isra")
	if enemigo != null:
		var _distancia = abs(position.x - enemigo.position.x)
	else:
		print("No se encontró enemigo.")

	# Si se está cubriendo, no permitir movimiento
	if Input.is_action_pressed("cubrirse"):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Ejes de entrada
	var direccion_x = Input.get_axis("direccionIzq", "direccionDer")
	var direccion_y = Input.get_axis("direccionArr", "direccionAba")

	# Asignar velocidad en ambos ejes
	velocity.x = movimiento * direccion_x
	velocity.y = movimiento * direccion_y
	
	var direccion := Vector2(direccion_x, direccion_y)
	if direccion.length() > 1:
		direccion = direccion.normalized()
	velocity = direccion * movimiento
	move_and_slide()

	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.flip_h = enemigo.position.x > position.x

func procesar_animacion() -> void:
	var enemigo = get_node_or_null("../soto")
	if enemigo == null:
		enemigo = get_node_or_null("../Isra")
	var distancia = 9999  # valor por defecto grande
	if enemigo != null:
		distancia = abs(position.x - enemigo.position.x)
	var anim = "PlayerIdle"
	if recibiendo_golpe:
		anim = "PlayerPunched"
	elif is_attacking:
		anim = "PlayerPunch"
	elif Input.is_action_pressed("cubrirse"):
		anim = "PlayerGuard"
	elif distancia < 50:
		anim = "PlayerIdle"
	elif abs(velocity.x) >= 0:
		anim = "PlayerWalk"

	reproducir_animacion(anim)
	

	reproducir_animacion(anim)


func procesar_ataque() -> void:
	if Input.is_action_just_pressed("golpe") and stamina > 24 and can_attack and not is_attacking and not recibiendo_golpe:
		iniciar_ataque()

func iniciar_ataque() -> void:
	is_attacking = true
	stamina -= 25
	can_attack = false
	$Golpe/Hitbox.monitoring = true

	await get_tree().create_timer(0.3).timeout

	$Golpe/Hitbox.monitoring = false
	is_attacking = false  # ← ESTO SE DEBE EJECUTAR SIEMPRE

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func on_player_attack():
	print("on_player_attack() llamado")
	if Input.is_action_pressed("cubrirse"):
		$AudioBloqueo.play()
		print("¡Bloqueó!")
	else:
		vida -= 10
		print("Vida actual:", vida)
		recibir_golpe()
	if vida <= 0:
		game_over()
	

func recibir_golpe() -> void:
	reproducir_animacion("PlayerPunched")
	$AudioGolpe.play()
	recibiendo_golpe = true
	await get_tree().create_timer(0.3).timeout
	recibiendo_golpe = false

func reproducir_animacion(nombre: String) -> void:
	if $AnimatedSprite2D.animation != nombre:
		$AnimatedSprite2D.play(nombre)

func game_over():
	if get_parent().has_node("EscenarioPrincipal"):
		var escenario = get_parent().get_node("EscenarioPrincipal")
		escenario.iniciar_animacion()
	emit_signal("game_over_triggered")  # Emitir la señal
	print("¡Juego terminado!")
	set_physics_process(false)
	
	
