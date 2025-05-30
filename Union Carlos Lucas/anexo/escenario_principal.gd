extends StaticBody2D

func _ready() -> void:
	iniciar_animacion()

func iniciar_animacion():
	$Timer/AnimatedSprite2D.play("default")
	$Timer.start((2.77 / 2))  # Aproximadamente 1.385 segundos

func reproducir_ring():
	iniciar_animacion()

func _on_timer_timeout() -> void:
	$Timer/AnimatedSprite2D.stop()
