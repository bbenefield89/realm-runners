extends CharacterBody2D


enum MovementStates {
	IDLE,
	WALKING,
	CHASING,
}

enum AttackStates {
	IDLE,
	SWINGING,
}

enum SwingingAttackStates {
	IDLE,
	CHARGING_UP,
	RELEASE,
	RESET,
}


@export var EnemySprite: AnimatedSprite2D
@export var WeaponSprite: Sprite2D
@export var RightWeaponSpriteRefPoint: Node2D
@export var LeftWeaponSpriteRefPoint: Node2D

@export var movement_speed: int
@export var swinging_attack_charging_up_speed: float
@export var max_swinging_attack_charging_up_rotation: float
@export var max_swinging_attack_release_rotation: float


var Player: PlayerController
var curr_movement_state: MovementStates
var curr_attack_state: AttackStates
var curr_swinging_attack_state: SwingingAttackStates


func _ready() -> void:
	curr_movement_state = MovementStates.IDLE
	curr_attack_state = AttackStates.IDLE


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack_primary"):
		curr_attack_state = AttackStates.SWINGING
		curr_swinging_attack_state = SwingingAttackStates.CHARGING_UP


func _physics_process(_delta: float) -> void:
	match curr_movement_state:
		MovementStates.IDLE:
			handle_idle_movement_state()
		
		MovementStates.WALKING:
			pass
			
		MovementStates.CHASING:
			handle_chasing_movement_state()
	
	move_and_slide()


func _process(delta: float) -> void:
	match curr_attack_state:
		AttackStates.IDLE:
			pass
		
		AttackStates.SWINGING:
			handle_swinging_attack_state(delta)


func handle_idle_movement_state():
	velocity = Vector2.ZERO
	EnemySprite.play("idle")


func handle_chasing_movement_state():
	var dist_from_player := (position - Player.position).length()
	var dir_to_player := (Player.position - position).normalized()
	
	if dist_from_player > 20:
		velocity = dir_to_player * movement_speed
	else:
		curr_movement_state = MovementStates.IDLE
	
	var should_flip_h := true if dir_to_player.x < 0 else false
	flip_sprites_horizontally(should_flip_h)
	EnemySprite.play("run")


func handle_swinging_attack_state(delta: float):
	match curr_swinging_attack_state:
		SwingingAttackStates.IDLE:
			handle_idle_swinging_attack_state()
		
		SwingingAttackStates.CHARGING_UP:
			handle_charging_up_swinging_attack_state(delta)
		
		SwingingAttackStates.RELEASE:
			handle_release_swinging_attack_state(delta)
		
		SwingingAttackStates.RESET:
			handle_reset_swinging_attack_state(delta)


func handle_idle_swinging_attack_state():
	WeaponSprite.rotation = 0


func handle_charging_up_swinging_attack_state(delta: float):
	WeaponSprite.rotation = max(
		WeaponSprite.rotation - swinging_attack_charging_up_speed * delta,
		max_swinging_attack_charging_up_rotation)
	
	var approximate_weapon_sprite_rotation := WeaponSprite.rotation - 0.10
	if approximate_weapon_sprite_rotation <= max_swinging_attack_charging_up_rotation:
		curr_swinging_attack_state = SwingingAttackStates.RELEASE


func handle_release_swinging_attack_state(delta: float):
	WeaponSprite.rotation = min(
		WeaponSprite.rotation + 10 * delta,
		max_swinging_attack_release_rotation)
	
	var approximate_weapon_sprite_rotation := WeaponSprite.rotation + 0.10
	if approximate_weapon_sprite_rotation >= max_swinging_attack_release_rotation:
		curr_swinging_attack_state = SwingingAttackStates.RESET


func handle_reset_swinging_attack_state(delta: float):
	WeaponSprite.rotation = max(
		WeaponSprite.rotation - 10 * delta,
		0.0)
	
	var approximate_weapon_sprite_rotation := WeaponSprite.rotation - 0.10
	if approximate_weapon_sprite_rotation <= 0.0:
		curr_swinging_attack_state = SwingingAttackStates.IDLE


func flip_sprites_horizontally(should_flip_h: bool):
	EnemySprite.flip_h = should_flip_h
	WeaponSprite.flip_h = should_flip_h
	WeaponSprite.position = (
		LeftWeaponSpriteRefPoint.position if should_flip_h else
		RightWeaponSpriteRefPoint.position)


func _on_aggro_range_body_entered(body: Node2D) -> void:
	if check_if_is_player(body):
		Player = body
		curr_movement_state = MovementStates.CHASING


func _on_aggro_range_body_exited(body: Node2D) -> void:
	if check_if_is_player(body):
		curr_movement_state = MovementStates.IDLE


func check_if_is_player(body: Node2D) -> bool:
	return true if (body.name as String).to_lower() == "player" else false












