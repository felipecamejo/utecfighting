extends CharacterBody2D

@export var team: int = 1
@export var movimiento := 200
@export var vida := 100
@export var stamina := 100.0
@export var block_chance := 0.3
@export var attack_cooldown: float = 0.3

#Hud
@onready var barraVida = $"../Hud/PlayerHud/barraVida"
@onready var barraStamina = $"../Hud/PlayerHud/barraStamina"


var is_attacking := false
var can_attack := true
var recibiendo_golpe := false
signal game_over_triggered #DISPARADOR PARA AVISAR AL CONTRARIO QUE MURIO

func _ready() -> void:
	$PosicionPrincipal.visible = false
	$Golpe/Hitbox.monitoring = false

func _physics_process(_delta):
	actualizar_stamina()
	actualizar_vida()
	procesar_movimiento()
	procesar_animacion()
	procesar_ataque()

func actualizar_stamina():
	if stamina < 100 and not is_attacking:
		stamina += 0.1
		if stamina > 100:
			stamina = 100
	barraStamina.value = stamina
	
func actualizar_vida():
	barraVida.value = vida

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
		print("¡Bloqueó!")
	else:
		vida -= 10
		print("Vida actual:", vida)
		recibir_golpe()
	if vida <= 0:
		game_over()
	

func recibir_golpe() -> void:
	reproducir_animacion("PlayerPunched")
	recibiendo_golpe = true
	await get_tree().create_timer(0.3).timeout
	recibiendo_golpe = false

func reproducir_animacion(nombre: String) -> void:
	if $AnimatedSprite2D.animation != nombre:
		$AnimatedSprite2D.play(nombre)

func game_over():
	emit_signal("game_over_triggered")  # Emitir la señal
	print("¡Juego terminado!")
	set_physics_process(false)
	
	# AQUI AGREGAR ESCENA DE JUGADOR VENCIDO POR UNOS SEGUNDOS O ANIMACION
	
