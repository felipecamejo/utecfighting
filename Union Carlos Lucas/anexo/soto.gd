extends CharacterBody2D

enum State { IDLE, MOVE, ATTACK, BLOCK, HIT, RETREAT }
var current_state = State.IDLE
var attack_completed = false
var retreat_distance = 0.0
var golpes = 0
var performing_action := false
var velocidades = [70, 100, 150, 250]
signal game_over_triggered

@onready var barraVida = $"../Hud/RivalHud/barraVida"
@onready var barraStamina = $"../Hud/RivalHud/barraStamina"
@onready var punch_cooldown_timer: Timer = $punch_cooldown_timer
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
	
func _physics_process(_delta):
	var distance = global_position.distance_to(personaje.global_position)
	$PosicionPrincipal.visible = true
	$SegundaPosicion.visible = false
	$Bloqueo.visible = false
	$Golpe.visible = false
	$GolpeRecibido.visible = false
	$Vencido1.visible = false
	$Vencido2.visible = false
	
	match current_state:
		State.IDLE:
			if distance < 350:
				current_state = State.MOVE
		State.MOVE:
			move_towards_player(_delta)
			if distance <= attack_distance:
				current_state = State.ATTACK
				attack_completed = false
		State.ATTACK:
			if not attack_completed:
				perform_attack()
		State.RETREAT:
			move_away_from_player()
			$AnimatedSprite2D.play("RivalWalk")
			speed = velocidades.pick_random()
			if distance >= attack_distance * retreat_distance_multiplier:
				current_state = State.MOVE
			
		State.BLOCK: 
			$PosicionPrincipal.visible = false
			$Bloqueo.visible = true
			await get_tree().create_timer(0.8).timeout
			current_state = State.MOVE
		State.HIT: 
			$PosicionPrincipal.visible = false
			$GolpeRecibido.visible = true
			await get_tree().create_timer(1.0).timeout
			current_state = State.RETREAT
			print(golpes)
	
func perform_attack():
	$Golpe.visible = true
	$AnimationPlayer.play("Golpe")
	await $AnimationPlayer.animation_finished
	$Golpe.visible = false
	attack_completed = true
	current_state = State.RETREAT
	retreat_distance = global_position.distance_to(personaje.global_position)
	
	
func move_towards_player(_delta):
	var direction = (personaje.global_position - global_position).normalized()
	set_velocity(direction * speed)
	$AnimationPlayer.play("Caminar")
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
	
func move_away_from_player(_delta):
	$AnimationPlayer.play("Caminar")
	#$PosicionPrincipal.visible = true
	#$Golpe.visible = false
	var direction = (personaje.global_position - global_position).normalized()
	var opposite_direction = -direction  # Invertimos la dirección
	set_velocity(opposite_direction * speed)
	move_and_slide()
	
func get_hit():
	current_state = State.HIT
	# Mejorar la reacción física # Configurar knockback
	var knockback_direction = (global_position - personaje.global_position).normalized()
	var knockback_power = 200
	var knockback_duration = 0.3
	var elapsed_time = 0.0
	golpes = golpes + 1
	
	# Aplicar knockback durante un tiempo corto
	while elapsed_time < knockback_duration and current_state == State.HIT:
		velocity = knockback_direction * knockback_power * (1.0 - elapsed_time/knockback_duration)
		move_and_slide()
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame
		
		velocity = Vector2.ZERO  # Detener el movimiento después del knockback
		await get_tree().create_timer(1.0 - knockback_duration).timeout # El resto del tiempo de hit
		
		if current_state == State.HIT:
			current_state = State.MOVE
			$GolpeRecibido.visible = false
			$PosicionPrincipal.visible = true
			
		$GolpeRecibido.visible = true
		$PosicionPrincipal.visible = true
		await get_tree().create_timer(0.5).timeout # Tiempo de im
		
		if current_state == State.HIT:
			current_state = State.MOVE
		

func on_player_attack():
	if current_state != State.HIT and current_state != State.BLOCK:
		if randf() < block_chance:  # 30% de probabilidad (block_chance = 0.4)
			current_state = State.BLOCK
			#print("¡Bloqueó el ataque!")
		else:
			current_state = State.HIT
			get_hit()  # Aplicar daño y retrocesoT
	
	
	
