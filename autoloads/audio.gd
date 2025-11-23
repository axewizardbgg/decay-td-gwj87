extends Node

# We'll make some groups, each with about 5-10 sound players ready to go
var groups: Dictionary = {
	"death": {
		"idx": 0,
		"snd_players": []
	},
	"burn": {
		"idx": 0,
		"snd_players": []
	},
	"attack": {
		"idx": 0,
		"snd_players": []
	},
	"effect": {
		"idx": 0,
		"snd_players": []
	},
}

var kinds: Dictionary = {
	"melee": [
		"res://sounds/Hit_1.mp3",
		"res://sounds/Hit_2.mp3",
		"res://sounds/Metal_Hit_1.mp3"
	],
	"arrow": [
		"res://sounds/ArrowShoot.mp3"
	],
	"fireball": [
		"res://sounds/shoot_fire.mp3"
	],
	"death": [
		"res://sounds/General_Death_1.mp3",
		"res://sounds/General_Death_2.mp3",
		"res://sounds/General_Death_3.mp3",
		"res://sounds/General_Death_4.mp3",
		"res://sounds/General_Death_5.mp3",
		"res://sounds/Peasant_Die_1.mp3",
		"res://sounds/Peasant_Die_2.mp3",
		"res://sounds/Wizard_Die_1.mp3",
		"res://sounds/Wizard_Die_2.mp3"
	],
	"burn": [
		"res://sounds/Burn_1.mp3",
		"res://sounds/Burn_2.mp3",
		"res://sounds/Burn_3.mp3",
		"res://sounds/Burn_4.mp3",
		"res://sounds/Burn_5.mp3",
		"res://sounds/Burn_6.mp3",
		"res://sounds/Burn_7.mp3",
	],
	"teleport": [
		"res://sounds/teleport.mp3"
	],
	"leech": [
		"res://sounds/leech.mp3"
	],
	"heal": [
		"res://sounds/heal.mp3"
	],
	"potion": [
		"res://sounds/potion.mp3"
	]
}

func _ready() -> void:
	# Initialize our groups
	for i in 3:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = "Combat"
		groups.death.snd_players.append(p)
		add_child(p)
	for i in 3:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = "Combat"
		groups.burn.snd_players.append(p)
		add_child(p)
	for i in 10:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = "Combat"
		groups.attack.snd_players.append(p)
		add_child(p)
	for i in 3:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = "Combat"
		groups.effect.snd_players.append(p)
		add_child(p)

func play_sound_death() -> void:
	_play_sound("death", "death")

func play_sound_burn() -> void:
	_play_sound("burn", "burn")

func play_sound_melee() -> void:
	_play_sound("attack", "melee")

func play_sound_arrow() -> void:
	_play_sound("attack", "arrow")

func play_sound_fireball() -> void:
	_play_sound("attack", "fireball")

func play_sound_teleport() -> void:
	_play_sound("effect", "teleport")

func play_sound_heal() -> void:
	_play_sound("effect", "heal")

func play_sound_leech() -> void:
	_play_sound("attack", "leech")

func play_sound_potion() -> void:
	_play_sound("attack", "potion")


func _play_sound(group: String, kind: String) -> void:
	# Does this group and kind exist?
	if !groups.has(group) || !kinds.has(kind):
		# No, do nothing
		return
	# Pick the sound player
	var p: AudioStreamPlayer = groups[group].snd_players[groups[group].idx]
	# Stop any playing sound, and load the new one
	p.stop()
	p.stream = load(kinds[kind][randi() % kinds[kind].size()])
	p.pitch_scale = randf_range(0.8, 1.1)
	p.play()
	# Advance our idx for next time (and ensure it stays within bounds)
	groups[group].idx += 1
	if groups[group].idx > groups[group].snd_players.size()-1:
		groups[group].idx = 0
	

func play_standalone_sound(snd_path: String, change_pitch: bool = false) -> void:
	# Set up a standalone sound player
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(p)
	p.stream = load(snd_path)
	if change_pitch:
		p.pitch_scale = randf_range(0.8, 1.1)
	# Play the sound
	p.play()
	# Ensure we clean it up once we're done with it
	p.finished.connect(_cleanup_player.bind(p))

func _cleanup_player(player: AudioStreamPlayer):
	if is_instance_valid(player):
		player.queue_free()
