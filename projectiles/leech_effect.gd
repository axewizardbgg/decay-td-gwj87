extends Node2D

var heal_amount: float # Expected to be set before _ready

var fired: bool = false

func _process(delta: float) -> void:
	if !fired:
		fired = true
		# Get all areas that are in our area
		var towers: Array = get_tree().get_nodes_in_group("towers")
		var heal_targets: Array[Node2D]
		# Determine who is within range of us
		for t in towers:
			if !is_instance_valid(t):
				continue
			# I was checking for range, but this caused a bug, just add them
			heal_targets.append(t)
		# Determine who we should heal
		var lowest: Node2D = null
		var lowest_pc: float = 100
		for h in heal_targets:
			if is_instance_valid(h):
				if is_instance_valid(lowest):
					var pc_life:float = (h.tower_data.life / h.life_max) * 100
					if pc_life < lowest_pc:
						lowest = h
						lowest_pc = pc_life
				else:
					lowest = h
		# Heal that target and create an effect on them
		if is_instance_valid(lowest):
			lowest.take_damage(-heal_amount, "heal", null)
			var e: Node2D = load("res://projectiles/SpellEffect.tscn").instantiate()
			e.animation_name = "leech"
			lowest.add_child(e)
		queue_free()
