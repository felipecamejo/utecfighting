extends Area2D

func _ready():
	# Solo conectar si no se hizo manualmente en el editor
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area2D: Area2D) -> void:
	# Primero chequeamos que el área tenga el grupo "hurtbox"
	if area2D.is_in_group("hurtbox"):
		var enemy = area2D.get_parent()
		# Validamos que enemy no sea null y tenga la propiedad team para comparar equipos
		if enemy.has_method("on_player_attack"):
			enemy.on_player_attack()
