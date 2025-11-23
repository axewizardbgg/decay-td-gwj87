extends Control

var victory: bool = false # Expected to be set before _ready

func _ready() -> void:
	# Play the song
	Audio.play_standalone_sound("res://sounds/WizardBreakdancer.mp3")
	# Is it victory or defeat?
	var v: String = "Victory"
	if !victory:
		v = "Defeat"
	# Prepare stats
	var s: String = "Stats:\n\nKills: "+str(Globals.stat_kills)+" | "
	s += "Damage: "+str(round(Globals.stat_damage))+" | "
	s += "Heals: "+str(round(Globals.stat_heals))+"\n"
	s += "\nUnit Count\n---------------\n"
	s += "Zombies: "+str(Globals.stat_zombies)+" | "
	s += "Skeletons: "+str(Globals.stat_skeles)+" | "
	s += "Skeleton Archers: "+str(Globals.stat_skele_archer)+"\n"
	s += "Warlocks: "+str(Globals.stat_warlock)+" | "
	s += "Demi Liches: "+str(Globals.stat_demilich)+"\n"
	s += "\nModifiers\n---------------\n"
	s += "Decay Rate: -"+str(round((Globals.mod_decay-1) * 100))+"% | "
	s += "Experience: +"+str(round((Globals.mod_exp-1) * 100))+"% | "
	s += "Resources: +"+str(round((Globals.mod_resource-1) * 100))+"%\n"
	s += "Damage: +"+str(round((Globals.mod_damage-1) * 100))+"% | "
	s += "Cooldown: -"+str(round((Globals.mod_action_interval-1) * 100))+"% | "
	s += "HP: +"+str(round((Globals.mod_life-1) * 100))+"%"
	
	# Set the stuff
	$CC/VBC/Result.text = v
	$CC/VBC/Stats.text = s
