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


class InventorySignalData:
	var node: GridContainer
	var callable: Callable
	
	func _init(_node: GridContainer, _callable: Callable):
		node = _node
		callable = _callable


@export var WeaponCenterRef: Node2D
@export var DamageFlashTimer: Timer
@export var DamageTimeoutTimer: Timer
@export var InventoryUi: Control
@export var InventoryEquipment: GridContainer
@export var InventoryContents: GridContainer
@export var ItemPickupArea: Area2D

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


func _physics_process(_delta: float):
	handle_movement()
	handle_WeaponSprite_movement()


func _input(_event: InputEvent):
	handle_attack_input()
	handle_BodySprite_facing_direction()
	handle_toggle_inventory()


func connect_signals(): # Called from CreatureController
	connect_Equipment_signals()
	connect_Inventory_signals([
		InventorySignalData.new(InventoryEquipment, _on_EquipmentBtn_pressed),
		InventorySignalData.new(InventoryContents, _on_InventoryContentBtn_pressed)])


func connect_Equipment_signals():
	Equipment.Weapon.weapon_hit_enemy.connect(_on_IronSword_weapon_hit_enemy)


func connect_Inventory_signals(inv_signals: Array[InventorySignalData]):
	for i in inv_signals.size():
		var InvContainer := inv_signals[i].node as GridContainer
		var callable := inv_signals[i].callable as Callable
		
		for child in InvContainer.get_children():
			var Btn := child as Button
			Btn.pressed.connect(callable)


func _on_IronSword_weapon_hit_enemy(Enemy: CreatureController) -> void:
	Enemy.handle_taking_damage(Equipment.Weapon.damage)


func _on_EquipmentBtn_pressed():
	print("Equipment Button Pressed")


func _on_InventoryContentBtn_pressed():
	print("Inventory Content Button Pressed")


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


func handle_toggle_inventory():
	if Input.is_action_just_pressed("inventory_toggle"):
		var is_inventory_visible = InventoryUi.visible
		InventoryUi.visible = false if is_inventory_visible else true


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


func handle_taking_damage(damage: int):
	if can_take_damage:
		can_take_damage = false
		BodySprite.modulate = Color.RED
		DamageFlashTimer.start()
		DamageTimeoutTimer.start()
		super.handle_taking_damage(damage)


func _on_damage_colors_timer_timeout() -> void:
	BodySprite.modulate = Color.RED if BodySprite.modulate == Color.WHITE else Color.WHITE


func _on_damage_timeout_timeout() -> void:
	can_take_damage = true
	BodySprite.modulate = Color.WHITE
	DamageFlashTimer.stop()


func _on_item_pickup_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is ItemController:
		print("Item found")






































