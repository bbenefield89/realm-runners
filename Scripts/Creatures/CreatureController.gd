extends CharacterBody2D
class_name CreatureController


enum LifeStates {
	ALIVE,
	DEAD,
}


@export var BodyCollisionShape: CollisionShape2D
@export var BodySprite: AnimatedSprite2D
@export var Equipment: EquipmentController
@export var stats: StatsResource

@export var movement_speed: int

var curr_life_state: LifeStates


func _ready():
	stats = stats.duplicate()
	stats.owner = self
	transition_to_life_state(LifeStates.ALIVE)
	connect_signals()


func transition_to_life_state(new_state: LifeStates):
	curr_life_state = new_state
	
	match new_state:
		LifeStates.ALIVE:
			pass
		
		LifeStates.DEAD:
			handle_dead_life_state()


func handle_dead_life_state():
	BodySprite.play("death")
	await BodySprite.animation_finished


func connect_signals():
	connect_Stats_signals()


func connect_Stats_signals():
	stats.creature_died.connect(_on_creature_died)


func _on_creature_died():
	transition_to_life_state(LifeStates.DEAD)


func handle_taking_damage(damage: int):
	stats.apply_damage(damage)





















