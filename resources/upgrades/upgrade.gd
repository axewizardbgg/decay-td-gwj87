class_name Upgrade
extends Resource

## What Modifier does this affect?
@export_enum(
	"mod_damage",
	"mod_decay",
	"mod_resource",
	"mod_action_interval",
	"mod_life",
	"mod_exp",
	"mod_spawn"
) var modifier: String = "mod_damage"

## How do we apply this benefit? (Positive or Negative?)
@export var positive: bool = true

## What's the magnitude of the upgrade?
@export var magnitude: float = 0.0

## How Rare is this upgrade (This is determined by the Magnitude)
@export_enum(
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"UNHOLY"
) var rarity: String = "Common"

## Description that is displayed on the button on the Level Up screen
@export var label_text: String = "+10% Damage"

## Apply the upgrade to our Globals stuff
func apply_upgrade() -> void:
	if positive:
		Globals[modifier] += magnitude
	else:
		Globals[modifier] -= magnitude
