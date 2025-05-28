extends Area2D

func _ready():
	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area2D: Area2D) -> void:
	if area2D.is_in_group("hurtbox"):
		var enemy = area2D.get_parent()
		if enemy.has_method("on_player_attack"):
			enemy.on_player_attack()
