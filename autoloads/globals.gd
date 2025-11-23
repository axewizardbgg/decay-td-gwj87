extends Node

signal unit_selected

# Making this game in the most lazy way possible, EVERYTHING IS ACCESSIBLE FROM ANYWHERE

# Levels and Experience
var experience: float = 0.0
var level: int = 1
var exp_to_level: float = 100.0 # Will scale off of level
var base_exp: float = 100.00

# Stats
var stat_kills: int = 0
var stat_damage: float = 0
var stat_heals: float = 0
var stat_zombies: int = 0
var stat_skeles: int = 0
var stat_skele_archer: int = 0
var stat_warlock: int = 0
var stat_demilich: int = 0

# Resources
var bones: int = 500 # Resource used to spawn towers/undead
var steel: int = 100 # For armored variants and archers
var magic: int = 0 # For magic variants

# Light and Decay
var lives: float = 100
var decay_rate: float = 1 # Should be between 0.5 and 2, scaled off of light perhaps?

# Spawning
var spawn_rate: float = 3 # In seconds, the time between spawns

# Upgrades
var mod_damage: float = 1 # Examples: 1.2 = +20% damage, 0.8 = -20% damage
var mod_decay: float = 1 # Examples: 1.2 = 20% faster, 0.8 = 20 slower
var mod_resource: float = 1 # Examples: 1.2 = 20% more resources, etc
var mod_action_interval: float = 1: 
	set(value):
		mod_action_interval = value # Examples: 1.2 = 20% slower, etc
		if mod_action_interval < 0.2:
			mod_action_interval = 0.2
var mod_life: float = 1 # Examples: 1.2 = 20% more health, 0.7 = -30% health, etc
var mod_exp: float = 1 # Examples: 1.2 = 20% more exp
var mod_spawn: float = 1 # Examples: 1.2 = 20% slower spawn rate

# What tower are we placing?
var selected_tower: String = "res://resources/towers/Zombie.tres":
	set(value):
		selected_tower = value
		emit_signal("unit_selected")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tower_1"):
		selected_tower = "res://resources/towers/Zombie.tres"
	if event.is_action_pressed("tower_2"):
		selected_tower = "res://resources/towers/Skele.tres"
	if event.is_action_pressed("tower_3"):
		selected_tower = "res://resources/towers/SkeleArcher.tres"
	if event.is_action_pressed("tower_4"):
		selected_tower = "res://resources/towers/PurpleMage.tres"
	if event.is_action_pressed("tower_5"):
		selected_tower = "res://resources/towers/BlackMage.tres"

func get_3_upgrades() -> Array[Upgrade]:
	# Get the Upgrade resources
	var ups: Array[String] = [
		"res://resources/upgrades/ActionInterval.tres",
		"res://resources/upgrades/Damage.tres",
		"res://resources/upgrades/Decay.tres",
		"res://resources/upgrades/Experience.tres",
		"res://resources/upgrades/Life.tres",
		"res://resources/upgrades/Resource.tres",
		"res://resources/upgrades/Spawn.tres"
	]
	
	# Pick 3 of those
	var choices: Array[String]
	for _i in 3:
		var c: int = randi() % ups.size()
		choices.append(ups[c])
		ups.remove_at(c)
	
	# Determine the magnitudes (10%, 15%, 20%, 25%, etc)
	var output: Array[Upgrade] = [
		load(choices[0]).duplicate(true),
		load(choices[1]).duplicate(true),
		load(choices[2]).duplicate(true)
	]
	for i in 3:
		var chance: int = randi_range(1, 100)
		if chance < 50:
			output[i].magnitude = 0.05
			output[i].rarity = "Common"
		elif chance < 70:
			output[i].magnitude = 0.10
			output[i].rarity = "Uncommon"
		elif chance < 80:
			output[i].magnitude = 0.15
			output[i].rarity = "Rare"
		elif chance < 90:
			output[i].magnitude = 0.20
			output[i].rarity = "Epic"
		elif chance < 97:
			output[i].magnitude = 0.25
			output[i].rarity = "Legendary"
		else:
			output[i].magnitude = 0.30
			output[i].rarity = "UNHOLY"
		# Label text
		var pos: String = "+"
		if !output[i].positive:
			pos = "-"
		output[i].label_text = "Rarity: "+output[i].rarity+"\n\n"
		output[i].label_text += pos+str(int(output[i].magnitude * 100))+"% "
		match output[i].modifier:
			"mod_damage":
				output[i].label_text += "Minion Damage"
			"mod_decay":
				output[i].label_text += "Decay Damage"
			"mod_resource":
				output[i].label_text += "Resources Gained"
			"mod_action_interval":
				output[i].label_text += "Attack Cooldown"
			"mod_life":
				output[i].label_text += "Minion HP"
			"mod_exp":
				output[i].label_text += "Experience Gained"
			"mod_spawn":
				output[i].label_text += "Slower Spawns"
	
	# Return the results
	return output
