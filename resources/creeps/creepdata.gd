class_name CreepData
extends Resource

## Which animation do we use for this Creep?
@export_enum(
	"h_knight",
	"h_peasant",
	"h_archer",
	"h_paladin",
	"h_priest",
	"h_wizard",
	"b_1",
	"b_2"
) var animation_name: String = "h_peasant"

## Which behavior should we use for this Creep?
@export_enum(
	"melee",
	"arrow",
	"fireball",
	"heal",
	"boss1",
	"boss2"
) var behavior: String = "melee"

## How much HP does this Creep have?
@export var life: float = 25 

## How fast does this Creep travel?
@export var spd: float = 10

## How much Light does this Creep add to the Pyre if they reach it?
@export var carried_light = 1

## How much damage does this Creep do if they are fighting?
@export var damage: float = 1

## How many seconds should elapse in between each action? (Attacking, casting, etc)
@export var action_interval: float = 1

## How much experience do we grant when we die?
@export var experience: float = 3.0

## What do we drop when we die?
@export var drop: Dictionary = {
	"bones": [50, 75],
	"steel": [0, 0],
	"magic": [0, 0]
}
