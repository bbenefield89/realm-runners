extends EnemyController


#enum AttackStates {
	#IDLE,
	#SWINGING,
#}
#
#enum SwingingAttackStates {
	#IDLE,
	#CHARGING_UP,
	#RELEASE,
	#RESET,
#}


#@export var swinging_attack_charging_up_speed: float
#@export var max_swinging_attack_charging_up_rotation: float
#@export var max_swinging_attack_release_rotation: float


#var curr_attack_state: AttackStates
#var curr_swinging_attack_state: SwingingAttackStates


#func _ready() -> void:
	#curr_attack_state = AttackStates.IDLE


#func _input(_event: InputEvent) -> void:
	#if Input.is_action_just_pressed("attack_primary"):
		#curr_attack_state = AttackStates.SWINGING
		#curr_swinging_attack_state = SwingingAttackStates.CHARGING_UP


#func _process(delta: float) -> void:
	#match curr_attack_state:
		#AttackStates.IDLE:
			#pass
		#
		#AttackStates.SWINGING:
			#handle_swinging_attack_state(delta)


#func handle_swinging_attack_state(delta: float):
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
	#Equipment.Weapon.rotation = max(
		#Equipment.Weapon.rotation - swinging_attack_charging_up_speed * delta,
		#max_swinging_attack_charging_up_rotation)
	#
	#var approximate_weapon_sprite_rotation := Equipment.Weapon.rotation - 0.10
	#if approximate_weapon_sprite_rotation <= max_swinging_attack_charging_up_rotation:
		#curr_swinging_attack_state = SwingingAttackStates.RELEASE
#
#
#func handle_release_swinging_attack_state(delta: float):
	#Equipment.Weapon.rotation = min(
		#Equipment.Weapon.rotation + 10 * delta,
		#max_swinging_attack_release_rotation)
	#
	#var approximate_weapon_sprite_rotation := Equipment.Weapon.rotation + 0.10
	#if approximate_weapon_sprite_rotation >= max_swinging_attack_release_rotation:
		#curr_swinging_attack_state = SwingingAttackStates.RESET
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

















