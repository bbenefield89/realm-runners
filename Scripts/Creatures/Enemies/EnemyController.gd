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


@export var WeaponRefPointRight: Node2D
@export var WeaponRefPointLeft: Node2D
@export var MeleeAttackArea: Area2D
@export var MeleeAttackTimer: Timer

#region Unused Weapon Vars
@export_group("Not used atm")
@export var swinging_attack_charging_up_speed: float
@export var max_swinging_attack_charging_up_rotation: float
@export var swinging_attack_release_speed: float
@export var max_swinging_attack_release_rotation: float
#endregion

var Player: PlayerController
var curr_movement_state: MovementStates
var curr_attack_state: AttackStates
var can_hit_player := false
var can_attack := true
var is_colliding_with_player := false


func _ready():
	super._ready()
	curr_movement_state = MovementStates.IDLE
	curr_attack_state = AttackStates.IDLE


func _physics_process(_delta: float) -> void:
	if curr_life_state != LifeStates.ALIVE:
		return
	
	handle_movement()


func _process(_delta: float) -> void:
	match curr_attack_state:
		AttackStates.IDLE:
			pass
		
		AttackStates.ATTACKING:
			handle_attacking_attack_state()


func handle_movement():
	match curr_movement_state:
		MovementStates.IDLE:
			handle_idle_movement_state()
		
		MovementStates.WALKING:
			pass
			
		MovementStates.CHASING:
			handle_chasing_movement_state()
		
	move_and_slide()


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


func _on_AggroArea_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		Player = body
		curr_movement_state = MovementStates.CHASING


func _on_AggroArea_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		curr_movement_state = MovementStates.IDLE


func _on_MeleeAttackArea_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		Player.take_damage(Equipment.Weapon.damage)
		MeleeAttackTimer.start()


func _on_melee_attack_area_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		MeleeAttackTimer.stop()
		curr_movement_state = MovementStates.CHASING


func _on_melee_attack_timer_timeout() -> void:
	Player.take_damage(Equipment.Weapon.damage)






























