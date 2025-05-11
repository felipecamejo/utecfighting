class_name Personaje
extends CharacterBody2D


@export var team: int = 1
@export var movimiento = 300

func _physics_process(_delta: float) -> void:
	
	$Sprite2D.visible = true
	$Sprite2D2.visible = false
	$Sprite2D3.visible = false
	$Sprite2D4.visible = false
	$Sprite2D5.visible = false
	$Sprite2D6.visible = false
	
	var direccionArriba = Input.get_axis("arriba","abajo")
	velocity.y = movimiento * direccionArriba 
	
	var direccion = Input.get_axis("izquierda","derecha") 
	velocity.x = movimiento * direccion
	
	if Input.is_action_pressed("cubrirse"):
		$Sprite2D.visible = false
		$Sprite2D4.visible = true
	elif Input.is_action_pressed("izquierda"):
		$Sprite2D.visible = false
		$Sprite2D6.visible = true
	elif Input.is_action_pressed("derecha"):
		$Sprite2D.visible = false
		$Sprite2D5.visible = true
	elif Input.is_action_pressed("golpeIzq"):
		$Sprite2D.visible = false
		$Sprite2D3.visible = true
	elif Input.is_action_pressed("golpe"):
		$Sprite2D.visible = false
		$Sprite2D2.visible = true
	else:
		$Sprite2D.visible = true
		
	# CONTROL DE HITBOX SEPARADO
	
	if Input.is_action_just_pressed("golpe"):
		$Sprite2D2/Hitbox.monitoring = true
		$Sprite2D2/Hitbox.visible = true # opcional, si quieres verla
		await get_tree().create_timer(0.5).timeout # Tiempo activa hitbox
		$Sprite2D2/Hitbox.monitoring = false
		$Sprite2D2/Hitbox.visible = false
	else:
		$Sprite2D2/Hitbox.monitoring = false
		$Sprite2D2/Hitbox.visible = false
		$Sprite2D3/Hitbox2.monitoring = false
		$Sprite2D3/Hitbox2.visible = false
		
	move_and_slide()
	
	

	
