extends CharacterBody2D
class_name PlayerController


enum MovementStates {
	IDLE,
	MOVING,
}

enum AttackingStates {
	IDLE,
	STABBING,
	SWINGING,
}


@export_group("Nodes")
@export var PlayerSprite: AnimatedSprite2D
@export var WeaponSprite: AnimatedSprite2D
@export var WeaponCenterRef: Node2D

@export_group("Settings")
@export var walk_speed: int
@export var max_weap_dist_from_center_point: int


var curr_movement_state: MovementStates
var curr_attacking_state: AttackingStates
var can_attack: bool = true


func _ready():
	transition_to_movement_state(MovementStates.IDLE)
	transition_to_attacking_state(AttackingStates.IDLE)


func _physics_process(_delta: float):
	handle_movement()
	handle_WeaponSprite_movement()


func _input(_event: InputEvent):
	handle_attack_input()
	handle_PlayerSprite_facing_direction()


func handle_movement():
	var input := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	velocity = input * walk_speed
	move_and_slide()
	
	if velocity != Vector2.ZERO:
		transition_to_movement_state(MovementStates.MOVING)
	else:
		transition_to_movement_state(MovementStates.IDLE)


func handle_WeaponSprite_movement():
	var curr_cursor_pos := get_global_mouse_position()
	var direction_to_cursor := (curr_cursor_pos - WeaponCenterRef.global_position).normalized()
	var distance_to_cursor = min((curr_cursor_pos - WeaponCenterRef.global_position).length(), max_weap_dist_from_center_point)
	var angle_to_cursor := atan2(direction_to_cursor.y, direction_to_cursor.x)
	WeaponSprite.global_position = WeaponCenterRef.global_position + direction_to_cursor * distance_to_cursor
	WeaponSprite.rotation = angle_to_cursor + PI / 2


func handle_PlayerSprite_facing_direction():
	var curr_cursor_pos := get_viewport().get_mouse_position()
	PlayerSprite.flip_h = true if curr_cursor_pos.x - position.x < 0 else false


func transition_to_movement_state(new_state: MovementStates):
	curr_movement_state = new_state
	
	match new_state:
		MovementStates.IDLE:
			handle_idle_state()
		
		MovementStates.MOVING:
			handle_moving_state()


func handle_idle_state():
	PlayerSprite.play("idle")


func handle_moving_state():
	PlayerSprite.play("walk")


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
	WeaponSprite.play("idle")


func handle_attack_stabbing_state():
	handle_attack_state("stab")


func handle_attack_swinging_state():
	handle_attack_state("swing")


func handle_attack_state(animation_name: String):
	if can_attack:
		can_attack = false
		WeaponSprite.play(animation_name)
		exit_attacking_state()


func exit_attacking_state():
	await WeaponSprite.animation_finished
	transition_to_attacking_state(AttackingStates.IDLE)











