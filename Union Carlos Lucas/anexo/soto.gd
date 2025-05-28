extends CharacterBody2D

enum State { IDLE, MOVE, ATTACK, BLOCK, HIT, RETREAT }
var current_state = State.IDLE
var attack_completed = false
var retreat_distance = 0.0
var golpes = 0

@onready var barraVida = $"../Hud/RivalHud/barraVida"
@onready var barraStamina = $"../Hud/RivalHud/barraStamina"
@export var vida := 100
@export var stamina := 100

@export var team: int = 2
@export var speed = 100
@export var attack_distance = 100
@export var block_chance = 0.3 # 30% probabilidad de bloquear
@export var retreat_distance_multiplier = 2.5
var personaje : Node2D

func _ready():
	personaje = get_parent().get_node("personaje")
	randomize()
	_ocultar_no_animatedsprites()

func _physics_process(_delta):
	barraVida.value = vida
	barraStamina.value = stamina
	
	_ocultar_no_animatedsprites()
	
	var distance = global_position.distance_to(personaje.global_position)

	match current_state:
		State.IDLE:
			$AnimatedSprite2D.play("RivalIdle")
			if distance < 350:
				current_state = State.MOVE
				
		State.MOVE:
			move_towards_player(_delta)
			$AnimatedSprite2D.play("RivalWalk")
			if distance <= attack_distance:
				current_state = State.ATTACK
				attack_completed = false
				
		State.ATTACK:
			if not attack_completed:
				perform_attack()
				
		State.RETREAT:
			move_away_from_player(_delta)
			$AnimatedSprite2D.play("RivalWalk")
			if distance >= attack_distance * retreat_distance_multiplier:
				current_state = State.MOVE
				
		State.BLOCK:
			$AnimatedSprite2D.play("RivalGuard")
			await get_tree().create_timer(0.8).timeout
			current_state = State.MOVE
			
		State.HIT:
			$AnimatedSprite2D.play("RivalPunched")
			await get_tree().create_timer(1.0).timeout
			current_state = State.RETREAT
			print(golpes)

func perform_attack():
	$AnimatedSprite2D.play("RivalPunch")
	await $AnimationPlayer.animation_finished
	attack_completed = true
	current_state = State.RETREAT
	retreat_distance = global_position.distance_to(personaje.global_position)
	
func move_towards_player(_delta):
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(direction * speed)
	move_and_slide()
	
func move_away_from_player(_delta):
	var direction = (personaje.global_position - global_position).normalized()
	var opposite_direction = -direction
	set_velocity(opposite_direction * speed)
	move_and_slide()
	
func get_hit():
	current_state = State.HIT
	var knockback_direction = (global_position - personaje.global_position).normalized()
	var knockback_power = 200
	var knockback_duration = 0.3
	var elapsed_time = 0.0
	golpes += 1
	
	while elapsed_time < knockback_duration and current_state == State.HIT:
		velocity = knockback_direction * knockback_power * (1.0 - elapsed_time / knockback_duration)
		move_and_slide()
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
		
	velocity = Vector2.ZERO
	await get_tree().create_timer(1.0 - knockback_duration).timeout
	
	if current_state == State.HIT:
		current_state = State.MOVE
	
	vida -= 10
	
	await get_tree().create_timer(0.5).timeout
	
	if current_state == State.HIT:
		current_state = State.MOVE
	
func on_player_attack():
	if current_state != State.HIT and current_state != State.BLOCK:
		if randf() < block_chance:
			current_state = State.BLOCK
		else:
			current_state = State.HIT
			get_hit()

func _ocultar_no_animatedsprites():
	for child in get_children():
		if child is AnimatedSprite2D:
			child.visible = true
		else:
			if "visible" in child:
				child.visible = false
