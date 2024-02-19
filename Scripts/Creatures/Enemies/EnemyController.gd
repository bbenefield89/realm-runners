extends CreatureController
class_name EnemyController


enum MovementStates {
	IDLE,
	WALKING,
	CHASING,
}


@export var WeaponRefPointRight: Node2D
@export var WeaponRefPointLeft: Node2D

var Player: PlayerController
var curr_movement_state: MovementStates


func _ready():
	super._ready()
	curr_movement_state = MovementStates.IDLE


func _physics_process(_delta: float) -> void:
	if curr_life_state == LifeStates.DEAD:
		return
	
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
	var dist_from_player := (position - Player.position).length()
	var dir_to_player := (Player.position - position).normalized()
	
	if dist_from_player > 20:
		velocity = dir_to_player * movement_speed
	else:
		curr_movement_state = MovementStates.IDLE
	
	var should_flip_h := true if dir_to_player.x < 0 else false
	flip_sprites_horizontally(should_flip_h)
	BodySprite.play("run")


func flip_sprites_horizontally(should_flip_h: bool):
	BodySprite.flip_h = should_flip_h
	Equipment.Weapon.flip_h = should_flip_h
	Equipment.Weapon.position = (
		WeaponRefPointLeft.position if should_flip_h else
		WeaponRefPointRight.position)




















