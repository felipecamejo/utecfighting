extends CharacterBody2D

@export var movimiento := 200
@export var vida := 100
@export var block_chance := 0.3
@export var attack_cooldown: float = 0.3

var is_attacking := false
var can_attack := true
var recibiendo_golpe := false

func _ready() -> void:
	$PosicionPrincipal.visible = false

func _physics_process(_delta):
	procesar_movimiento()
	procesar_animacion()
	procesar_ataque()

func procesar_movimiento() -> void:
	var enemigo = $"../soto" # Cambia según estructura real
	var _distancia = abs(position.x - enemigo.position.x)
	var direccion = Input.get_axis("direccionIzq", "direccionDer")
	velocity.x = movimiento * direccion
	move_and_slide()

	if direccion != 0:
		$AnimatedSprite2D.flip_h = enemigo.position.x > position.x

func procesar_animacion() -> void:
	var enemigo = $"../soto"
	var distancia = abs(position.x - enemigo.position.x)
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


func procesar_ataque() -> void:
	if Input.is_action_just_pressed("golpe") and can_attack and not is_attacking and not recibiendo_golpe:
		iniciar_ataque()

func iniciar_ataque() -> void:
	is_attacking = true
	can_attack = false
	$Golpe/Hitbox.monitoring = true

	await get_tree().create_timer(0.3).timeout

	$Golpe/Hitbox.monitoring = false
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func on_player_attack():
	print("on_player_attack() llamado")
	if Input.is_action_pressed("cubrirse"):
		print("¡Bloqueó!")
	else:
		vida -= 10
		print("Vida actual:", vida)
		recibir_golpe()

func recibir_golpe() -> void:
	reproducir_animacion("PlayerPunched")
	recibiendo_golpe = true
	await get_tree().create_timer(0.3).timeout
	recibiendo_golpe = false

func reproducir_animacion(nombre: String) -> void:
	if $AnimatedSprite2D.animation != nombre:
		$AnimatedSprite2D.play(nombre)
