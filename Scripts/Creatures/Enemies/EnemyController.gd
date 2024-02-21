extends CreatureController
class_name EnemyController


enum MovementStates {
	IDLE,
	WALKING,
	CHASING,
}

enum AttackStates {
	IDLE,
	ATTACKING,
}

#enum SwingingAttackStates {
	#IDLE,
	#CHARGING_UP,
	#RELEASE,
	#RESET,
#}


@export var WeaponRefPointRight: Node2D
@export var WeaponRefPointLeft: Node2D

@export var swinging_attack_charging_up_speed: float
@export var max_swinging_attack_charging_up_rotation: float

@export var swinging_attack_release_speed: float
@export var max_swinging_attack_release_rotation: float

var Player: PlayerController
var curr_movement_state: MovementStates
var curr_attack_state: AttackStates
#var curr_swinging_attack_state: SwingingAttackStates
var can_hit_player := false
var can_attack := true


func _ready():
	super._ready()
	curr_movement_state = MovementStates.IDLE
	curr_attack_state = AttackStates.IDLE


func _physics_process(_delta: float) -> void:
	if curr_life_state != LifeStates.ALIVE:
		return
	
	match curr_movement_state:
		MovementStates.IDLE:
			handle_idle_movement_state()
		
		MovementStates.WALKING:
			pass
			
		MovementStates.CHASING:
			handle_chasing_movement_state()
		
	move_and_slide()


func _process(_delta: float) -> void:
	match curr_attack_state:
		AttackStates.IDLE:
			pass
		
		AttackStates.ATTACKING:
			handle_attacking_attack_state()


func connect_signals():
	connect_Weapon_signals()


func connect_Weapon_signals():
	Equipment.Weapon.release_animation_finished.connect(_on_Weapon_release_animation_finished)


func handle_idle_movement_state():
	velocity = Vector2.ZERO
	BodySprite.play("idle")


func handle_chasing_movement_state():
	var dir_to_player := (Player.position - position).normalized()
	var should_flip_h := true if dir_to_player.x < 0 else false
	
	velocity = dir_to_player * movement_speed
	flip_sprites_horizontally(should_flip_h)
	BodySprite.play("run")


func flip_sprites_horizontally(should_flip_h: bool):
	BodySprite.flip_h = should_flip_h
	Equipment.Weapon.flip_h = should_flip_h
	Equipment.Weapon.position = (
		WeaponRefPointLeft.position if should_flip_h else
		WeaponRefPointRight.position)


func handle_idle_attack_state():
	can_attack = true


func handle_attacking_attack_state():
	if can_attack:
		can_attack = false
		Equipment.Weapon.curr_attack_state = WeaponController.AttackStates.CHARGE_UP
	
	#match curr_swinging_attack_state:
		#SwingingAttackStates.IDLE:
			#handle_idle_swinging_attack_state()
		#
		#SwingingAttackStates.CHARGING_UP:
			#handle_charging_up_swinging_attack_state(delta)
		#
		#SwingingAttackStates.RELEASE:
			#handle_release_swinging_attack_state(delta)
		#
		#SwingingAttackStates.RESET:
			#handle_reset_swinging_attack_state(delta)
#
#
#func handle_idle_swinging_attack_state():
	#Equipment.Weapon.rotation = 0
#
#
#func handle_charging_up_swinging_attack_state(delta: float):
	#var rotation_direction := 1 if BodySprite.flip_h else -1
	#Equipment.Weapon.rotation += rotation_direction * swinging_attack_charging_up_speed * delta
	#
	#var has_reached_desired_rotation := false
	#var approximate_weapon_sprite_rotation := Equipment.Weapon.rotation - 0.10
	#if BodySprite.flip_h:
		#has_reached_desired_rotation = approximate_weapon_sprite_rotation >= abs(max_swinging_attack_charging_up_rotation)
	#else:
		#has_reached_desired_rotation = approximate_weapon_sprite_rotation <= max_swinging_attack_charging_up_rotation
	#
	#if has_reached_desired_rotation:
		#curr_swinging_attack_state = SwingingAttackStates.RELEASE
#
#
#func handle_release_swinging_attack_state(delta: float):
	#var rotation_direction := -1 if BodySprite.flip_h else 1
	#Equipment.Weapon.rotation += rotation_direction * swinging_attack_release_speed * delta
	#
	#var has_reached_desired_rotation := false
	#var approximate_weapon_sprite_rotation := Equipment.Weapon.rotation + 0.10
	#if BodySprite.flip_h:
		#has_reached_desired_rotation = approximate_weapon_sprite_rotation <= max_swinging_attack_release_rotation * -1
	#else:
		#has_reached_desired_rotation = approximate_weapon_sprite_rotation >= max_swinging_attack_release_rotation
	#
	#if has_reached_desired_rotation:
		#curr_swinging_attack_state = SwingingAttackStates.RESET
		#
		#if can_hit_player:
			#print("Applying damage to: ", Player.name)
			#Player.stats.apply_damage(Equipment.Weapon.damage)
#
#
#func handle_reset_swinging_attack_state(delta: float):
	#Equipment.Weapon.rotation = max(
		#Equipment.Weapon.rotation - 10 * delta,
		#0.0)
	#
	#var approximate_weapon_sprite_rotation := Equipment.Weapon.rotation - 0.10
	#if approximate_weapon_sprite_rotation <= 0.0:
		#curr_swinging_attack_state = SwingingAttackStates.IDLE


func _on_AggroArea_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		Player = body
		curr_movement_state = MovementStates.CHASING


func _on_AggroArea_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		curr_movement_state = MovementStates.IDLE


func _on_MeleeAttackArea_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		can_hit_player = true
		curr_movement_state = MovementStates.IDLE
		curr_attack_state = AttackStates.ATTACKING
		BodySprite.play("idle")


func _on_MeleeAttackArea_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		can_hit_player = false


func _on_Weapon_release_animation_finished(damage: int):
	if can_hit_player:
		Player.stats.apply_damage(damage)





















