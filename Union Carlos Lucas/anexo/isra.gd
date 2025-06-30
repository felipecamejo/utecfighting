extends CharacterBody2D

enum State { IDLE, MOVE, ATTACK, BLOCK, HIT, RETREAT, FEINT }
var current_state = State.IDLE
var golpes = 0
var performing_action := false
signal game_over_triggered

@onready var barraVida = $"../Hud/RivalHud/Vida"
@onready var punch_cooldown_timer: Timer = $punch_cooldown_timer

@onready var spriteHud = $"../Hud/RivalHud/AnimatedSprite2D"

@export var vida := 50
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

var ya_decidio_timer := false

func actualizar_SpriteHud():
	if vida <= 25 / 2 :
		spriteHud.frame = 3
	elif vida <= 50 / 2:
		spriteHud.frame = 2
	elif vida <= 75 / 2:
		spriteHud.frame = 1
	else:
		spriteHud.frame = 0


func _physics_process(_delta):
	barraVida.value = vida * 2
	actualizar_SpriteHud()
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
			$AnimatedSprite2D.play("RivalIdle") #Walk
			move_towards_player()

			if distance < attack_distance and not punch_cooldown_timer.is_stopped():
				speed = velocidades.pick_random()
				current_state = State.RETREAT
			elif distance < attack_distance and punch_cooldown_timer.is_stopped():
				if randi() % 6 == 0:
					current_state = State.FEINT
				else:
					speed = velocidades.pick_random()
					current_state = State.ATTACK

		State.ATTACK:
			start_attack()
			await get_tree().create_timer(0.1).timeout

			var decision = randi() % 3  # 0: RETREAT, 1: BLOCK, 2: MOVE
			match decision:
				0:
					current_state = State.RETREAT
				1:
					current_state = State.BLOCK
					start_block()
				2:
					speed = velocidades.pick_random()
					current_state = State.MOVE

		State.RETREAT:
			$AnimatedSprite2D.play("RivalIdle") #Walk
			speed = 100
			move_away_from_player()
			if distance >= attack_distance * retreat_distance_multiplier:
				speed = velocidades.pick_random()
				current_state = State.MOVE

		State.BLOCK:
			start_block()

		State.FEINT:
			move_towards_player()
			$AnimatedSprite2D.play("RivalIdle")#Walk
			await get_tree().create_timer(randf_range(0.2, 0.4)).timeout
			var decision = randi() % 2
			if decision == 0:
				current_state = State.ATTACK
			else:
				speed = velocidades.pick_random()
				current_state = State.RETREAT

func move_towards_player():
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(direction * speed)
	move_and_slide()

func move_away_from_player():
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(-direction * speed)
	move_and_slide()

func start_attack():
	performing_action = true
	$AnimatedSprite2D.play("RivalPunch")
	$Golpe/HitArea.monitoring = true
	punch_cooldown_timer.start()
	await get_tree().create_timer(0.6).timeout
	$Golpe/HitArea.monitoring = false
	ya_decidio_timer = false
	performing_action = false

func start_block():
	performing_action = true
	$AnimatedSprite2D.play("RivalGuard")
	$AudioBloqueo.play()
	await get_tree().create_timer(0.8).timeout
	current_state = State.MOVE
	performing_action = false

func start_hit():
	performing_action = true
	$AnimatedSprite2D.play("RivalPunched")
	$AudioGolpe.play()
	golpes += 1
	vida -= 10

	if vida <= 0:
		game_over()

	var knockback_distance = 50
	var direction = (global_position - personaje.global_position).normalized()
	var knockback_target = global_position + direction * knockback_distance
	var knockback_time = 0.2
	var elapsed = 0.0
	var step_time = 0.02

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
				cancelar_accion_actual()
				start_hit()

func cancelar_accion_actual():
# Detén cualquier animación relevante
	$AnimatedSprite2D.stop()
# Desactiva el área de golpe si estaba activa
	$Golpe/HitArea.monitoring = false
	# Detén timers si es necesario
	punch_cooldown_timer.stop()
	# Restablece la variable de acción
	performing_action = false

func _ocultar_no_animatedsprites():
	for child in get_children():
		if child is AnimatedSprite2D:
			child.visible = true
		elif "visible" in child:
			child.visible = false

func desactivar_movimiento():
	set_physics_process(false)
	if self.vida <= 0:
		$AnimatedSprite2D.play("RivalDefeated")
	elif personaje.vida <= 0:
		personaje.get_node("AnimatedSprite2D").play("PlayerDefeated")

	if get_parent().has_node("EscenarioPrincipal"):
		var escenario = get_parent().get_node("EscenarioPrincipal")
		escenario.iniciar_animacion()
	print("Movimiento desactivado")

func game_over():
	emit_signal("game_over_triggered")
	print("¡Juego terminado!")
	await get_tree().create_timer(1.0).timeout
	desactivar_movimiento()
