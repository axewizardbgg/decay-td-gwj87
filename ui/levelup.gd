extends Control

# We'll need to keep track of which upgrades we're choosing from
var upgrades: Array[Upgrade]

# Prevent us from clicking a button for the first second
var t: float = 1

func _ready() -> void:
	# Get 3 randomized upgrades
	upgrades = Globals.get_3_upgrades()
	
	# Prepare our Buttons and add them as children
	for i in upgrades.size():
		var btn: Button = Button.new()
		btn.text = upgrades[i].label_text
		# Apply the theme variation based on the rarity
		match upgrades[i].rarity:
			"Common":
				btn.theme_type_variation = "ButtonCommon"
				btn.pressed.connect(_choice_made.bind(i, "Common"))
			"Uncommon":
				btn.theme_type_variation = "ButtonUncommon"
				btn.pressed.connect(_choice_made.bind(i, "Uncommon"))
			"Rare":
				btn.theme_type_variation = "ButtonRare"
				btn.pressed.connect(_choice_made.bind(i, "Rare"))
			"Epic":
				btn.theme_type_variation = "ButtonEpic"
				btn.pressed.connect(_choice_made.bind(i, "Epic"))
			"Legendary":
				btn.theme_type_variation = "ButtonLegendary"
				btn.pressed.connect(_choice_made.bind(i, "Legendary"))
			"UNHOLY":
				btn.theme_type_variation = "ButtonUNHOLY"
				btn.pressed.connect(_choice_made.bind(i, "UNHOLY"))
		$CC/VBC/Buttons.add_child(btn)
	

func _choice_made(idx: int, rarity: String):
	# Unpause the game
	get_tree().paused = false
	# Play the sound
	match rarity:
		"Common":
			Audio.play_standalone_sound("res://sounds/Rarity_Common.mp3")
		"Uncommon":
			Audio.play_standalone_sound("res://sounds/Rarity_Uncommon.mp3")
		"Rare":
			Audio.play_standalone_sound("res://sounds/Rarity_Rare.mp3")
		"Epic":
			Audio.play_standalone_sound("res://sounds/Rarity_Epic.mp3")
		"Legendary":
			Audio.play_standalone_sound("res://sounds/Rarity_Legendary.mp3")
		"UNHOLY":
			Audio.play_standalone_sound("res://sounds/Rarity_UNHOLY.mp3")
	# Apply the upgrade
	upgrades[idx].apply_upgrade()
	# Remove this screen!
	queue_free()

func _process(delta: float) -> void:
	t -= delta
	if t <= 0:
		$MouseShield.mouse_filter = Control.MOUSE_FILTER_IGNORE
