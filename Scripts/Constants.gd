extends Node
class_name Constants


class InputActions:
	var attack_primary := "attack_primary"
	var attack_secondary := "attack_secondary"


class Groups:
	var enemy := "Enemy"
	var weapon := "Weapon"


class Creatures:
	var player := "Player"


static var inputActions := InputActions.new()
static var groups := Groups.new()
static var creatures := Creatures.new()
