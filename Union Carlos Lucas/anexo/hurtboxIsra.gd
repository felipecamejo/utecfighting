extends Area2D


signal _damaged(damage :int)

@export var defense := 10
@export_enum("No es jugador", "Jugador", "Enemigo") var team := 0

'''func hurt(hit_area: HitArea) -> int:
	var damage: int = max(0, hit_area.damage - defense)
	damaged.emit(damage)
	return damage'''
# En esta funcion se debe recibir el danio
