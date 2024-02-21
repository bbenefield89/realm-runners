extends Resource
class_name StatsResource


@export var max_health: int
@export var curr_health: int

var owner: CreatureController


signal creature_died()


func apply_damage(damage: int):
	print("%s has taken %d damage" % [owner.name, damage])
	curr_health -= damage
	
	if curr_health <= 0:
		creature_died.emit()























