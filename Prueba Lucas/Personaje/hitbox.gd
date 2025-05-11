class_name HitArea
extends Area2D

signal hit_landed(damage: int)

@export var damage := 10
@export_enum("No es jugador", "Jugador", "Neutral", "Aspecto Solar") var team := 0


		
func _on_area_entered(area2D: Area2D) -> void:
	if area2D.is_in_group("hurtbox") and area2D.get_parent().team != self.team:
		var enemy = area2D.get_parent()
		if enemy != null and enemy.has_method("get_hit"):
			enemy.on_player_attack()
			# Opcional: Pasar daño
