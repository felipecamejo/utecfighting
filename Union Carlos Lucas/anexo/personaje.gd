class_name Personaje
extends CharacterBody2D


@export var team: int = 1
@export var movimiento = 200
@export var attack_cooldown: float = 0.2  # Tiempo de espera entre ataques
var is_attacking: bool = false
var can_attack: bool = true  # Controla el cooldown
@export var block_chance = 0.3 # 30% probabilidad de bloquear
@export var vida := 100

func _physics_process(_delta: float) -> void:
	$PosicionPrincipal.visible = true
	$Paso.visible = false
	$Golpe.visible = false
	$Cubrirse.visible = false
	$GolpeRecibido.visible = false
	
	var direccion = Input.get_axis("direccionIzq", "direccionDer")
	velocity.x = movimiento * direccion
	
	if Input.is_action_pressed("cubrirse"):
		$PosicionPrincipal.visible = false
		$Cubrirse.visible = true
	elif Input.is_action_pressed("golpe") and position.x < 500:
		$Golpe.scale.x = -abs($Golpe.scale.x) #Sirve para espejar
		$PosicionPrincipal.visible = false
		$Golpe.visible = true
	elif Input.is_action_pressed("golpe"):
		$Golpe.scale.x = abs($Golpe.scale.x) #Volver a espejar para dejar en posicion inicial
		$PosicionPrincipal.visible = false
		$Golpe.visible = true
	elif position.x < 500:
		$Paso.scale.x = abs($Paso.scale.x)
		$PosicionPrincipal.visible = false
		$Paso.visible = true
	elif $".".position.x > 700:
		$Paso.scale.x = -abs($Paso.scale.x)
		$PosicionPrincipal.visible = false
		$Paso.visible = true
	else:
		$PosicionPrincipal.visible = true
		
	if Input.is_action_just_pressed("golpe") and can_attack and not is_attacking:
		is_attacking = true
		can_attack = false
		$Golpe/Hitbox.monitoring = true
		$Golpe/Hitbox.visible = true # opcional, si quieres verla
		await get_tree().create_timer(0.3).timeout # Tiempo activa hitbox
		$Golpe/Hitbox.monitoring = false
		$Golpe/Hitbox.visible = false
		is_attacking = false
		
		await get_tree().create_timer(attack_cooldown).timeout  # Cooldown
		can_attack = true
		#Se implementa cooldown para no spamear click
		
	else:
		$Golpe/Hitbox.monitoring = false
		$Golpe/Hitbox.visible = false



	move_and_slide()
	
func on_player_attack():
	if randf() < block_chance and $Cubrirse.visible == true:
		print("¡Bloqueó el ataque!")
	else:
		vida -= 10
		get_hit()
		print(name, " recibió daño! Vida: ", vida)
		
	#if vida <= 0:
	#	queue_free()
			
func get_hit():
	$AnimationPlayer.play("GolpeRecibido")
	await $AnimationPlayer.animation_finished
	
	
	
	
