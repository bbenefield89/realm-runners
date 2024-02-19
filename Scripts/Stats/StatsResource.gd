extends Resource
class_name StatsResource


@export var max_health: int
@export var curr_health: int


signal creature_died()


func apply_damage(damage: int):
	curr_health -= damage
	
	if curr_health <= 0:
		creature_died.emit()
