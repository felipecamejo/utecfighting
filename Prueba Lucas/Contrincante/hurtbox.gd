class_name HurtArea
extends Area2D


signal damaged(damage :int)

@export var defense: = 0
@export_enum("No es jugador", "Jugador", "Neutral", "Aspecto Solar") var team := 0

func hurt(hit_area: HitArea) -> int:
	var damage: int = max(0, hit_area.damage - defense)
	damaged.emit(damage)
	return damage
	
