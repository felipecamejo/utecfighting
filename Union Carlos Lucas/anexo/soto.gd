extends CharacterBody2D

enum State { IDLE, MOVE, ATTACK, BLOCK, HIT, RETREAT }
var current_state = State.IDLE
var golpes = 0
var performing_action := false
signal game_over_triggered

@onready var barraVida = $"../Hud/RivalHud/barraVida"
@onready var barraStamina = $"../Hud/RivalHud/barraStamina"
@onready var punch_cooldown_timer: Timer = $punch_cooldown_timer
@export var vida := 100
@export var stamina := 100

@export var team: int = 2
@export var speed = 100
@export var attack_distance = 100
@export var block_chance = 0.3
@export var retreat_distance_multiplier = 2.5
var personaje : Node2D
var velocidades = [70, 100, 150, 250]

func _ready():
	personaje = get_parent().get_node("personaje")
	randomize()
	_ocultar_no_animatedsprites()
	punch_cooldown_timer.one_shot = true
	$Golpe/HitArea.monitoring = false
	personaje.game_over_triggered.connect(desactivar_movimiento)
	

func _physics_process(_delta):
	barraVida.value = vida
	barraStamina.value = stamina

	_ocultar_no_animatedsprites()
	if performing_action:
		return

	var distance = global_position.distance_to(personaje.global_position)

	match current_state:
		State.IDLE:
			$AnimatedSprite2D.play("RivalIdle")
			if distance < 350:
				speed = velocidades.pick_random()
				current_state = State.MOVE

		State.MOVE:
			print(speed)
			move_towards_player()
			$AnimatedSprite2D.play("RivalWalk")
			if distance < attack_distance and not punch_cooldown_timer.is_stopped():
				speed = velocidades.pick_random()
				current_state = State.RETREAT
			elif distance < attack_distance and punch_cooldown_timer.is_stopped():
				speed = velocidades.pick_random()
				current_state = State.ATTACK
				
		State.ATTACK:
			start_attack()
			speed = velocidades.pick_random()
			current_state = State.RETREAT
			
		State.RETREAT:
			speed = 100
			move_away_from_player()
			$AnimatedSprite2D.play("RivalWalk")
			if distance >= attack_distance * retreat_distance_multiplier:
				speed = velocidades.pick_random()
				current_state = State.MOVE

func move_towards_player():
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(direction * speed)
	move_and_slide()

var ya_decidio_timer := false  # variable de control para la decisión del timer

func move_away_from_player():
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(-direction * speed)
	move_and_slide()

	# Decidir solo una vez en el ciclo RETREAT antes del próximo ataque
	if not ya_decidio_timer and current_state == State.RETREAT:
		var random_value = randi_range(1, 3)  # 1, 2 o 3
		punch_cooldown_timer.one_shot = (random_value <= 2)  # true si 1 o 2 (66%) # SIEMPRE TRUE PARA QUE GOLPEE
		ya_decidio_timer = true
		print("Decidió punch_cooldown_timer.one_shot =", punch_cooldown_timer.one_shot)



func start_attack():
	performing_action = true
	$AnimatedSprite2D.play("RivalPunch")
	$Golpe/HitArea.monitoring = true
	punch_cooldown_timer.start()
	await get_tree().create_timer(0.6).timeout
	current_state = State.RETREAT
	$Golpe/HitArea.monitoring = false
	ya_decidio_timer = false  # Reseteamos para la próxima vez que ataque
	performing_action = false


func start_block():
	performing_action = true
	$AnimatedSprite2D.play("RivalGuard")
	await get_tree().create_timer(0.8).timeout
	current_state = State.MOVE
	performing_action = false

func start_hit():
	performing_action = true
	$AnimatedSprite2D.play("RivalPunched")
	golpes += 1
	vida -= 10
	
	if vida<=0:
		game_over()

	# Aplicar knockback simple
	var knockback_distance = 50
	var direction = (global_position - personaje.global_position).normalized()
	var knockback_target = global_position + direction * knockback_distance

	var knockback_time = 0.2
	var elapsed = 0.0
	var step_time = 0.02  # pequeño delay entre pasos

	while elapsed < knockback_time:
		global_position = global_position.lerp(knockback_target, 0.1)
		await get_tree().create_timer(step_time).timeout
		elapsed += step_time

	await get_tree().create_timer(1.0).timeout
	current_state = State.RETREAT
	performing_action = false



func on_player_attack():
	var distance = global_position.distance_to(personaje.global_position)
	if distance <= attack_distance:
		if not performing_action:
			if randf() < block_chance:
				current_state = State.BLOCK
				start_block()
			else:
				current_state = State.HIT
				start_hit()

func _ocultar_no_animatedsprites():
	for child in get_children():
		if child is AnimatedSprite2D:
			child.visible = true
		elif "visible" in child:
			child.visible = false
			
func desactivar_movimiento():
	set_physics_process(false)
	print("Movimiento desactivado")
	
func game_over():
	# AQUI AGREGAR ANIMACION DE SOTO VENCIDO POR UNOS SEGUNDOS
	emit_signal("game_over_triggered") # CON ESTA SEÑAL PODEMOS PONER UNA VICTORIA (jugador saltando o algo)
	print("¡Juego terminado!")
	State.RETREAT
	await get_tree().create_timer(1.0).timeout
	desactivar_movimiento()
	
