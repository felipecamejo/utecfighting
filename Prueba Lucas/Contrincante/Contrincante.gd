class_name Contrincante
extends CharacterBody2D
'''
IDLE → esperando
MOVE → acercándose al jugador
ATTACK → atacando
BLOCK → cubriéndose si detecta ataque del jugador
HIT → retrocediendo al ser golpeado
'''

enum State { IDLE, MOVE, ATTACK, BLOCK, HIT }
var current_state = State.IDLE

@export var team: int = 2
@export var speed = 100
@export var attack_distance = 50
@export var block_chance = 0.3 # 30% probabilidad de bloquear
var personaje : Node2D

func _ready():
	personaje = get_parent().get_node("personaje")
	randomize()
	print("Hurtbox global:", $Hurtbox.global_position)
	

func _physics_process(_delta):
	var distance = global_position.distance_to(personaje.global_position)
	$"IsraPosicion-sinfondo".visible = true
	#$Isra2daPosicion.visible = false
	$"IsraGolpe-sinfondo".visible = false
	$IsraCubre.visible = false
	$IsraLaRecibe.visible = false
	#move_towards_player(_delta)
	#move_and_slide()

	match current_state:
		State.IDLE:
			if distance < 200:
				current_state = State.MOVE
		State.MOVE:
			move_towards_player(_delta)
			if distance <= attack_distance:
				current_state = State.ATTACK
		State.ATTACK:
			if current_state != State.MOVE:
				$"IsraPosicion-sinfondo".visible = false
				#$Isra2daPosicion.visible = false
				$"IsraGolpe-sinfondo".visible = true
				if distance > attack_distance:
					current_state = State.MOVE
		State.BLOCK:
			$"IsraPosicion-sinfondo".visible = false
			#$Isra2daPosicion.visible = false
			$IsraCubre.visible = true
			await get_tree().create_timer(0.8).timeout
			current_state = State.MOVE
		State.HIT:
			$"IsraPosicion-sinfondo".visible = false
			$Isra2daPosicion.visible = false
			$IsraLaRecibe.visible = true
			await get_tree().create_timer(1.0).timeout
			current_state = State.MOVE

func move_towards_player(_delta):
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(direction * speed)
	move_and_slide()
	$AnimationPlayer.play("golpe")
	
func perform_attack():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("Reposo")
	await get_tree().create_timer(0.7).timeout
	current_state = State.MOVE

func get_hit():
	current_state = State.HIT
	# Mejorar la reacción física
	var knockback_direction = (global_position - personaje.global_position).normalized()
	velocity = knockback_direction * 200 # Aumentar fuerza retroceso
	move_and_slide()
	await get_tree().create_timer(1.3).timeout
	current_state = State.MOVE
	
	# Animación y tiempo de recuperación
	$IsraLaRecibe.visible = true
	$"IsraPosicion-sinfondo".visible = false
	await get_tree().create_timer(0.5).timeout # Tiempo de impacto
	
	# Volver a estado MOVE solo si sigue en HIT
	if current_state == State.HIT:
		current_state = State.MOVE
	
	
func on_player_attack():
	if current_state != State.HIT and current_state != State.BLOCK:
		if randf() < block_chance:  # 30% de probabilidad (block_chance = 0.4)
			current_state = State.BLOCK
			print("¡Bloqueó el ataque!")
		else:
			current_state = State.HIT
			get_hit()  # Aplicar daño y retrocesoT
	
	
	
