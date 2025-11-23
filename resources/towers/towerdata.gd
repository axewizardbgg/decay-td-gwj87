class_name TowerData
extends Resource

## Which animation do we use for this Tower?
@export_enum(
	"e_zombie",
	"e_skele",
	"e_skele_archer",
	"e_black_mage",
	"e_purple_mage"
) var animation_name: String = "e_zombie"

## Which behavior best suits this Tower?
@export_enum(
	"melee",
	"arrow",
	"fireball",
	"leech"
) var behavior: String = "melee"

## How much HP does this Tower have?
@export var life: float = 10

## How fast can this Tower move, if at all?
@export var spd: float = 0

## How much damage does this Tower do?
@export var damage: float = 5

## How many seconds should elapse in between each action? (Attacking, casting, etc)
@export var action_interval: float = 1

## What resources are required for us to be placed?
@export var required_resources: Dictionary = {
	"bones": 50,
	"steel": 0,
	"magic": 0
}

## What is the title of this unit?
@export var title: String

## Description that is displayed on the tooltip that describes what this tower is
@export var description: String 
