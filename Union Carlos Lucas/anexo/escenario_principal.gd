extends StaticBody2D

@onready var audio_player: AudioStreamPlayer = $AudioAmbiente

func _ready() -> void:
	iniciar_animacion()
	audio_player.finished.connect(_on_audio_finished)

func iniciar_animacion():
	$AudioCampana.play()
	$Timer/AnimatedSprite2D.visible = true
	$Timer/AnimatedSprite2D.play("default")
	$Timer.start((2.77 / 2))

func reproducir_ring():
	iniciar_animacion()

func _on_timer_timeout() -> void:
	$Timer/AnimatedSprite2D.stop()
	$Timer/AnimatedSprite2D.visible = false

func _on_audio_finished():
	print("Audio terminado. Reiniciando...")
	audio_player.play()  # Vuelve a reproducir
