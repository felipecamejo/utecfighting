#class_name HurtArea
extends Area2D

@export var damage := 10
@export_enum("No es jugador", "Jugador", "Enemigo") var team := 0


func _on_area_entered(area: Area2D):
	# Todas las verificaciones necesarias
	if !area: return
	if !area.is_in_group("hurtbox"): return
	
	var target = area.get_parent()
	if !target: return
	if !("team" in target): return
	
	# Conversión explícita a int
	var attacker_team := int(self.team)
	var target_team := int(target.team)
	
	if attacker_team == target_team: return
	
	# Llamada segura al método
	if "on_player_attack" in target:
		target.on_player_attack.call_deferred()  # Versión segura para threads
