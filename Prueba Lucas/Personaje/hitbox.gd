class_name HitArea
extends Area2D

signal hit_landed(damage: int)

@export var damage := 10
@export_enum("No es jugador", "Jugador", "Neutral", "Aspecto Solar") var team := 0


		
func _on_area_entered(area2D: Area2D) -> void:
	print("Jugador herido")
	#hit(area2D)
	

'''func hit(hurt_area: HurtArea) -> void:
	if not hurt_area.team == team:
		if self is HitArea:  # Verifica que "self" sea un HitArea
			hit_landed.emit(hurt_area.hurt(self))
		else:
			push_error("El objeto no es un HitArea")'''
		
