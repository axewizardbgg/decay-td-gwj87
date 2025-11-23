extends PathFollow2D

signal creep_death

## Expected to be set before ready is called
@export var creep_data: CreepData

# Whether or not we are moving
var move: bool = true
# Keep track of a target
var target: Node2D
var action_timer: float = 0.0
var action_count: int = 0 # Used to determine if Mages can teleport

# UI stuff
var life_max: float

# Stuff used in calculations
var _melee_range: float = 32
var _ranged_range: float = 128
var _heal_range: float = 256
var y_offset: float # Determined in _ready

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	y_offset = (4 * scale.y) * -1
	life_max = (creep_data.life * (1+ (Globals.level * 0.06)))
	creep_data.life = life_max
	# Add ourselves to the creeps group
	add_to_group("creeps")
	# Set our sprite to play
	$AnimatedSprite2D.play(creep_data.animation_name)
	# Adjust the radius of our collision shape
	match creep_data.behavior:
		"melee":
			$Area2D/CollisionShape2D.shape.radius = _melee_range / 2
		"arrow", "fireball":
			$Area2D/CollisionShape2D.shape.radius = _ranged_range / 2
		"heal":
			$Area2D/CollisionShape2D.shape.radius = _heal_range / 2


func _process(delta: float) -> void:
	# Have we reached the end?
	if progress_ratio >= 1.0:
		# We have, SACRIFICE TO THE FLAME
		Audio.play_sound_burn()
		Globals.lives -= creep_data.carried_light
		queue_free()
		return
		
	# Increment our action timer
	action_timer += delta * (1 + (Globals.level * 0.01))
	
	# Update our healthbar
	var pc_life: float = 0
	if creep_data.life > 0:
		pc_life = (creep_data.life / life_max) * 100
	$ProgressBar.value = pc_life
	
	# Here we do different things depending on our behavior
	match creep_data.behavior:
		"melee", "boss1":
			_melee_process(delta)
		"arrow", "fireball", "boss2":
			_ranged_process(delta)
		"heal":
			_heal_process(delta)
	
	# Ensure bosses are always moving
	if creep_data.behavior == "boss1" || creep_data.behavior == "boss2":
		move = true
	
	# Are we moving?
	if move:
		# We are, move along our path
		progress += (creep_data.spd + ((Globals.level-1) * 0.1)) * delta

func take_damage(amount: float, kind: String, who: Node2D) -> void:
	# Ensure we're not doubling up on this in case we take multiple damage in the same frame
	if creep_data.life <= 0:
		# Nothing to do, stop execution
		return
	# Take the damage!
	creep_data.life -= amount
	if kind != "heal":
		Globals.stat_damage += amount
	# Are we dead yet?
	if creep_data.life <= 0:
		# We're dead bro!
		Globals.stat_kills += 1
		# Add resources
		var b: int = randi_range(creep_data.drop.bones[0], creep_data.drop.bones[1])
		var s: int = randi_range(creep_data.drop.steel[0], creep_data.drop.steel[1])
		var m: int = randi_range(creep_data.drop.magic[0], creep_data.drop.magic[1])
		@warning_ignore("narrowing_conversion")
		Globals.bones += (b * Globals.mod_resource)
		@warning_ignore("narrowing_conversion")
		Globals.steel += (s * Globals.mod_resource)
		@warning_ignore("narrowing_conversion")
		Globals.magic += (m * Globals.mod_resource)
		# Increase exp
		Globals.experience += (creep_data.experience * Globals.mod_exp)
		# Play a sound of us dying!
		Audio.play_sound_death()
		emit_signal("creep_death")
		queue_free()
		return
	# Since we can heal with this too, ensure our life is not above our max
	if creep_data.life > life_max:
		creep_data.life = life_max
	# We're still alive! Should this be our new target?
	if creep_data.behavior == "melee":
			# Is the kind of damage we took also melee?
			if kind == "melee":
				# Yea, Do we already have a target?
				if !is_instance_valid(target):
					# We don't have a valid target, update our target
					target = who
	# We're still alive! Should this be our new target?
	if creep_data.behavior == "arrow" || creep_data.behavior == "fireball":
			# Is the kind of damage we took also ranged?
			if kind == "ranged":
				# Yea, they're shooting as us! Is whoever shot at us still a valid instance?
				if !is_instance_valid(who):
					# They are, SHOOT EM BACK
					target = who
			if kind == "melee":
				# We're being attacked by melee, stop moving
				move = false
	# Did we get healed?
	if kind == "heal":
		# We did, make a heal effect
		var e: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
		e.animation_name = "heal"
		add_child(e)
	

func _melee_process(delta: float) -> void:
	# We're melee! First of all, do we have a target?
	if is_instance_valid(target):
		# We do, can we attack it?
		if action_timer >= creep_data.action_interval:
			# Yes, are we in range?
			if global_position.distance_to(target.global_position) <= _melee_range:
				# Attack! Also reset action timer
				var e: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
				e.animation_name = "swipe"
				add_child(e)
				e.position.y += y_offset
				e.rotation = (target.global_position-global_position).angle()
				target.take_damage(creep_data.damage, "melee", self)
				action_timer = 0
				Audio.play_sound_melee()
				move = false
			else:
				# Not in range, just clear target
				target = null
				move = true
		else:
			# We still have a valid target, but it's not yet time to attack, stay still
			move = false
	else:
		# No valid target, ensure its cleared, and set it so we can move
		target = null
		move = true

func _ranged_process(delta: float) -> void:
	# We're ranged! First of all, do we have a target?
	if is_instance_valid(target):
		# We do, can we attack it?
		if action_timer >= creep_data.action_interval:
			# Yes, are we in range?
			if global_position.distance_to(target.global_position) <= _ranged_range:
				# Attack! Get the closest target
				target = _find_closest_target()
				# Are we shooting an arrow or throwing a fireball?
				if creep_data.behavior == "arrow":
					var arrow: Node2D = load("res://projectiles/Arrow.tscn").instantiate()
					arrow.target = target
					arrow.who = self
					arrow.damage = creep_data.damage
					get_tree().root.add_child(arrow)
					arrow.global_position = global_position
					Audio.play_sound_arrow()
				elif creep_data.behavior == "boss2":
					var potion: Node2D = load("res://projectiles/Ball.tscn").instantiate()
					potion.target = target
					potion.who = self
					potion.damage = creep_data.damage
					potion.animation_name = "potion"
					get_tree().root.add_child(potion)
					potion.global_position = global_position
					Audio.play_sound_arrow()
				else:
					# First, do we need to teleport?
					if action_count == 0:
						# We do! Grab everyone around us (our second Area2D)
						var peeps: Array[Area2D] = $Area2D2.get_overlapping_areas()
						# How far are we teleporting?
						var dist: float = (200 + ((Globals.level+1) * 5))
						for p in peeps:
							# Teleport them ahead
							if is_instance_valid(p.owner):
								# Is this a boss?
								if p.owner.creep_data.animation_name == "b_1" || p.owner.creep_data.animation_name == "b_2":
									# It's a boss! Do nothing
									continue
								p.owner.progress += dist
								var e: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
								e.animation_name = "teleport"
								p.owner.add_child(e)
						# Teleport myself as well
						progress += dist
						var e2: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
						e2.animation_name = "teleport"
						add_child(e2)
						Audio.play_sound_teleport()
						# Increment our action counter
						action_count += 1
						if action_count >= 5:
							action_count = 0 # Only want the mage to teleport people every 5 attacks
					var ball: Node2D = load("res://projectiles/Ball.tscn").instantiate()
					ball.target = target
					ball.who = self
					ball.damage = creep_data.damage
					get_tree().root.add_child(ball)
					ball.global_position = global_position
					Audio.play_sound_fireball()
				action_timer = 0
			else:
				# Not in range, just clear target
				target = null
				move = true
	else:
		# No valid target, find another target
		target = _find_closest_target()
		move = true
	

func _heal_process(delta: float) -> void:
	# We're a healer! Can we heal?
	if action_timer >= creep_data.action_interval:
		# Get a fresh target
		target = _find_heal_target()
		# Heal! Also reset action timer
		if is_instance_valid(target):
			target.take_damage(-creep_data.damage, "heal", self)
			Audio.play_sound_heal()
		action_timer = 0

func _find_heal_target() -> Node2D:
	# Get all the people within range
	var col: Array[Area2D] = $Area2D.get_overlapping_areas()
	var heal_targets: Array[Node2D]
	for c in col:
		# Is this thing in our Area part of our group?
		if c.owner.is_in_group("creeps"):
			# It is, add it to our pool of heal targets
			heal_targets.append(c.owner)
	# Determine the lowest health target (by percentage)
	var lowest: Node2D = null
	var lowest_pc: float = 100
	for h in heal_targets:
		if is_instance_valid(h):
			if is_instance_valid(lowest):
				var pc_life:float = (h.creep_data.life / h.life_max) * 100
				if pc_life < lowest_pc:
					lowest = h
					lowest_pc = pc_life
			else:
				lowest = h
	# Return it so we can heal them!
	return lowest



func _find_closest_target() -> Node2D:
	# Get all the towers
	var towers: Array = get_tree().get_nodes_in_group("towers")
	# Determine closest tower
	var closest: Node2D = null
	var closest_dist: float = 0.0
	for tower in towers:
		var t: Node2D = tower
		if !is_instance_valid(closest):
			closest = t
			closest_dist = global_position.distance_to(t.global_position)
			continue
		var dist: float = global_position.distance_to(t.global_position)
		if dist < closest_dist:
			closest = t
			closest_dist = dist
	return closest


# Automatically created signal connector function from the node tab
func _on_area_2d_area_entered(area: Area2D) -> void:
	# Is the the we're colliding with a tower?
	if !area.owner.is_in_group("towers"):
		# No, nothing to do here
		return
	# It is a Tower, what should we do?
	match creep_data.behavior:
		"melee":
			# We encountered something as melee, do we have a target?
			if !is_instance_valid(target):
				# We do not, but now we do!
				target = area.owner
				move = false
		"ranged":
			# Do we have a target?
			if !is_instance_valid(target):
				# We do now
				target = area.owner
		"boss1":
			# First, determine if they're even valid
			if !is_instance_valid(area.owner):
				# Not valid, do nothing
				return
			# We have a valid enemy, immediately attack it, regardless of cooldown
			target = area.owner
			var e: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
			e.animation_name = "swipe"
			add_child(e)
			e.position.y += y_offset
			e.rotation = (target.global_position-global_position).angle()
			target.take_damage(creep_data.damage, "melee", self)
			action_timer = 0
			Audio.play_sound_melee()
