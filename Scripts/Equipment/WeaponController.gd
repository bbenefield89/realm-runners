extends AnimatedSprite2D
class_name WeaponController


@export var menu_name: String
@export var damage: int


signal weapon_hit_enemy(body: Node2D)


func _on_weapon_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(Constants.groups.enemy):
		weapon_hit_enemy.emit(body as CreatureController)
