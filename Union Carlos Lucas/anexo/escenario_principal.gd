extends StaticBody2D

func _ready() -> void:
	iniciar_animacion()

func iniciar_animacion():
	$Timer/AnimatedSprite2D.visible = true
	$Timer/AnimatedSprite2D.play("default")
	$Timer.start((2.77 / 2))

func reproducir_ring():
	iniciar_animacion()

func _on_timer_timeout() -> void:
	$Timer/AnimatedSprite2D.stop()
	$Timer/AnimatedSprite2D.visible = false
