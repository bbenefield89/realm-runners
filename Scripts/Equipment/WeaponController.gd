extends AnimatedSprite2D
class_name WeaponController


enum AttackStates {
	IDLE,
	CHARGE_UP,
	RELEASE,
	RESET,
}


@export var menu_name: String
@export var damage: int
@export var is_players_weapon: bool
@export var charge_up_speed: float
@export var max_charge_up_rotation: float
@export var release_speed: float
@export var max_release_rotation: float

var curr_attack_state: AttackStates


signal weapon_hit_enemy(body: Node2D)
signal release_animation_finished(damage: int)


func _ready():
	curr_attack_state = AttackStates.IDLE


func _process(delta: float) -> void:
	if not is_players_weapon:
		match curr_attack_state:
			AttackStates.IDLE:
				handle_idle_attack_state()
			
			AttackStates.CHARGE_UP:
				handle_charge_up_attack_state(delta)
			
			AttackStates.RELEASE:
				handle_release_attack_state(delta)
			
			AttackStates.RESET:
				handle_reset_attack_state(delta)


func handle_idle_attack_state():
	rotation = 0


func handle_charge_up_attack_state(delta: float):
	var rotation_direction := 1 if flip_h else -1
	rotation += rotation_direction * charge_up_speed * delta
	
	var has_reached_desired_rotation := false
	var approximate_weapon_sprite_rotation := rotation - 0.10
	if flip_h:
		has_reached_desired_rotation = approximate_weapon_sprite_rotation >= abs(max_charge_up_rotation)
	else:
		has_reached_desired_rotation = approximate_weapon_sprite_rotation <= max_charge_up_rotation
	
	if has_reached_desired_rotation:
		curr_attack_state = AttackStates.RELEASE


func handle_release_attack_state(delta: float):
	var rotation_direction := -1 if flip_h else 1
	rotation += rotation_direction * release_speed * delta
	
	var has_reached_desired_rotation := false
	var approximate_weapon_sprite_rotation := rotation + 0.10
	if flip_h:
		has_reached_desired_rotation = approximate_weapon_sprite_rotation <= max_release_rotation * -1
	else:
		has_reached_desired_rotation = approximate_weapon_sprite_rotation >= max_release_rotation
	
	if has_reached_desired_rotation:
		curr_attack_state = AttackStates.RESET
		release_animation_finished.emit(damage)


func handle_reset_attack_state(delta: float):
	rotation += 10 * delta
	
	var approximate_weapon_sprite_rotation := rotation - 0.10
	if approximate_weapon_sprite_rotation <= 0.0:
		curr_attack_state = AttackStates.IDLE


# This is only used for Player -> Enemy combat
func _on_weapon_collision_area_body_entered(body: Node2D) -> void:
	if body is EnemyController:
		weapon_hit_enemy.emit(body as CreatureController)



































