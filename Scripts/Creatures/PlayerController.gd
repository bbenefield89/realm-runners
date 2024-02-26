extends CreatureController
class_name PlayerController


enum MovementStates {
	IDLE,
	MOVING,
	DAMAGED,
}

enum AttackingStates {
	IDLE,
	STABBING,
	SWINGING,
}


@export var WeaponCenterRef: Node2D
@export var DamageFlashTimer: Timer
@export var DamageTimeoutTimer: Timer

@export var max_weap_dist_from_center_point: int
@export var max_damage_flash_time: float

var curr_movement_state: MovementStates
var curr_attacking_state: AttackingStates
var can_attack := true
var can_take_damage := true
var total_time_damage_flashing := 0.0


func _ready():
	super._ready()
	transition_to_movement_state(MovementStates.IDLE)
	transition_to_attacking_state(AttackingStates.IDLE)
	connect_Equipment_signals()


func _physics_process(_delta: float):
	handle_movement()
	handle_WeaponSprite_movement()


func _input(_event: InputEvent):
	handle_attack_input()
	handle_BodySprite_facing_direction()


func handle_movement():
	if not curr_life_state == LifeStates.DEAD:
		var input := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
		velocity = input * movement_speed
		
		if not curr_movement_state == MovementStates.DAMAGED:
			if velocity != Vector2.ZERO:
				transition_to_movement_state(MovementStates.MOVING)
			else:
				transition_to_movement_state(MovementStates.IDLE)
		
		move_and_slide()


func handle_WeaponSprite_movement():
	var curr_cursor_pos := get_global_mouse_position()
	var direction_to_cursor := (curr_cursor_pos - WeaponCenterRef.global_position).normalized()
	var distance_to_cursor = min((curr_cursor_pos - WeaponCenterRef.global_position).length(), max_weap_dist_from_center_point)
	var angle_to_cursor := atan2(direction_to_cursor.y, direction_to_cursor.x)
	Equipment.Weapon.global_position = WeaponCenterRef.global_position + direction_to_cursor * distance_to_cursor
	Equipment.Weapon.rotation = angle_to_cursor + PI / 2


func handle_BodySprite_facing_direction():
	var curr_cursor_pos := get_viewport().get_mouse_position()
	BodySprite.flip_h = true if curr_cursor_pos.x - position.x < 0 else false


func transition_to_movement_state(new_state: MovementStates):
	curr_movement_state = new_state
	
	match new_state:
		MovementStates.IDLE:
			handle_idle_state()
		
		MovementStates.MOVING:
			handle_moving_state()
		
		MovementStates.DAMAGED:
			handle_damaged_state()


func handle_idle_state():
	BodySprite.play("idle")


func handle_moving_state():
	BodySprite.play("walk")


func handle_damaged_state():
	BodySprite.play("taking_damage")


func handle_attack_input():
	if Input.is_action_just_pressed("attack_primary"):
		transition_to_attacking_state(AttackingStates.SWINGING)
	
	elif Input.is_action_just_pressed("attack_secondary"):
		transition_to_attacking_state(AttackingStates.STABBING)


func transition_to_attacking_state(new_state: AttackingStates):
	curr_attacking_state = new_state
	
	match new_state:
		AttackingStates.IDLE:
			handle_attack_idle_state()
		
		AttackingStates.STABBING:
			handle_attack_stabbing_state()
		
		AttackingStates.SWINGING:
			handle_attack_swinging_state()


func handle_attack_idle_state():
	can_attack = true
	Equipment.Weapon.play("idle")


func handle_attack_stabbing_state():
	handle_attack_state("stab")


func handle_attack_swinging_state():
	handle_attack_state("swing")


func handle_attack_state(animation_name: String):
	if can_attack:
		can_attack = false
		Equipment.Weapon.play(animation_name)
		exit_attacking_state()


func exit_attacking_state():
	await Equipment.Weapon.animation_finished
	transition_to_attacking_state(AttackingStates.IDLE)


func handle_dead_life_state():
	await super.handle_dead_life_state()
	get_tree().change_scene_to_file("res://Scenes/GameOverScene.tscn")


func take_damage(damage: int):
	if can_take_damage:
		can_take_damage = false
		BodySprite.modulate = Color.RED
		stats.apply_damage(damage)
		DamageFlashTimer.start()
		DamageTimeoutTimer.start()


func _on_damage_colors_timer_timeout() -> void:
	BodySprite.modulate = Color.RED if BodySprite.modulate == Color.WHITE else Color.WHITE


func _on_damage_timeout_timeout() -> void:
	can_take_damage = true
	BodySprite.modulate = Color.WHITE
	DamageFlashTimer.stop()


func connect_Equipment_signals():
	Equipment.Weapon.weapon_hit_enemy.connect(_on_IronSword_weapon_hit_enemy)


func _on_IronSword_weapon_hit_enemy(Enemy: CreatureController) -> void:
	Enemy.stats.apply_damage(Equipment.Weapon.damage)



































