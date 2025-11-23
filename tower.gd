extends Node2D

## Expected to be set before _ready
@export var tower_data: TowerData

# Targeting and stuff
var target: Node2D
var decay_timer: float = 1
var action_timer: float = 0.0
var move: bool = false

# UI stuff
var life_max: float # Set in _ready

# Stuff used in calculations
var _melee_range: float = 32
var _ranged_range: float = 128
var y_offset: float # Determined in _ready

func _ready() -> void:
	y_offset = (4 * scale.y) * -1
	# Set our max life
	life_max = tower_data.life * Globals.mod_life
	tower_data.life = life_max
	add_to_group("towers")
	$AnimatedSprite2D.play(tower_data.animation_name)
	
	# Stats
	match tower_data.animation_name:
		"e_zombie":
			Globals.stat_zombies += 1
		"e_skele":
			Globals.stat_skeles += 1
		"e_skele_archer":
			Globals.stat_skele_archer += 1
		"e_purple_mage":
			Globals.stat_warlock += 1
		"e_black_mage":
			Globals.stat_demilich += 1

func _process(delta: float) -> void:
	# Are we within the bounds of the screen?
	if global_position.x > 648 || global_position.x < -8 || global_position.y > 368 || global_position.y < -8:
		queue_free()
		return
	# Decay
	decay_timer -= (delta * Globals.decay_rate)
	if decay_timer <= 0:
		var d: float = (1 * Globals.mod_decay)
		if d < 0.2:
			d = 0.2
		tower_data.life -= d
		decay_timer = (1 * Globals.decay_rate)
	
	# Ensure we don't somehow go over our max health
	if tower_data.life > life_max:
		tower_data.life = life_max
	
	# Are we cooked chat?
	if tower_data.life <= 0:
		queue_free()
		return
	
	# Update our health bar
	var pc_life: float = 0
	if tower_data.life > 0:
		pc_life = (tower_data.life / life_max) * 100
	$ProgressBar.value = pc_life
	
	# Increment our action timer
	action_timer += delta
	
	# Determine what to do based on behavior
	match tower_data.behavior:
		"melee":
			_melee_process(delta)
		"arrow", "fireball", "leech":
			_ranged_process(delta)
				
func _melee_process(delta: float) -> void:
	# Do we have a target?
	if is_instance_valid(target):
		# We do, are we close enough to attack?
		if global_position.distance_to(target.global_position) <= _melee_range:
			# We are, can we attack?
			if action_timer >= (tower_data.action_interval * Globals.mod_action_interval):
				# We can, attack!
				var e: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
				e.animation_name = "swipe"
				add_child(e)
				e.position.y += y_offset
				e.rotation = (target.global_position-global_position).angle()
				target.take_damage((tower_data.damage * Globals.mod_damage), "melee", self)
				Audio.play_sound_melee()
				action_timer = 0
			else:
				# Target still valid, and within range, we're just on cooldown. Don't move
				move = false
		else:
			# We need to get closer
			move = true
	else:
		# No target, find one
		target = _find_closest_target()
		if is_instance_valid(target):
			move = true
		else:
			move = false
	# Can we move?
	if move:
		var motion: Vector2 = Vector2(1,0).rotated((target.global_position-global_position).angle())
		motion = motion * tower_data.spd * delta
		translate(motion)

func _ranged_process(delta: float) -> void:
	# We're ranged! First of all, do we have a target?
	if is_instance_valid(target):
		# We do, can we attack it?
		if action_timer >= (tower_data.action_interval * Globals.mod_action_interval):
			# Yes, are we in range?
			if global_position.distance_to(target.global_position) <= _ranged_range:
				# Attack! Also reset action timer
				if tower_data.behavior == "arrow":
					var arrow: Node2D = load("res://projectiles/Arrow.tscn").instantiate()
					arrow.target = target
					arrow.who = self
					arrow.damage = (tower_data.damage * Globals.mod_damage)
					get_tree().root.add_child(arrow)
					arrow.global_position = global_position
					Audio.play_sound_arrow()
				elif tower_data.behavior == "fireball":
					var ball: Node2D = load("res://projectiles/Ball.tscn").instantiate()
					ball.target = target
					ball.who = self
					ball.damage = (tower_data.damage * Globals.mod_damage)
					ball.animation_name = "purple_fireball"
					get_tree().root.add_child(ball)
					ball.global_position = global_position
					Audio.play_sound_fireball()
				else:
					var ball: Node2D = load("res://projectiles/Ball.tscn").instantiate()
					ball.target = target
					ball.who = self
					ball.damage = (tower_data.damage * Globals.mod_damage)
					ball.animation_name = "leech"
					get_tree().root.add_child(ball)
					ball.global_position = global_position
					Audio.play_sound_leech()
				action_timer = 0
			else:
				# Not in range, just clear target
				target = null
				move = true
		else:
			# We still have a valid target, but it's not yet time to attack, stay still
			move = false
	else:
		# No valid target, find the closest target, and move if needed
		target = _find_closest_target()
		move = true
	# Are we moving?
	if move:
		if !is_instance_valid(target):
			return
		var motion: Vector2 = Vector2(1,0).rotated((target.global_position-global_position).angle())
		motion = motion * tower_data.spd * delta
		translate(motion)



func _find_closest_target() -> Node2D:
	# Get all the creeps
	var creeps: Array = get_tree().get_nodes_in_group("creeps")
	# Determine closest creep
	var closest: Node2D = null
	var closest_dist: float = 0.0
	for creep in creeps:
		var c: Node2D = creep
		if !is_instance_valid(closest):
			closest = c
			closest_dist = global_position.distance_to(c.global_position)
			continue
		var dist: float = global_position.distance_to(c.global_position)
		if dist < closest_dist:
			closest = c
			closest_dist = dist
	return closest

func take_damage(amount: float, kind: String, who: Node2D) -> void:
	# Ensure we're not doubling up on this in case we take multiple damage in the same frame
	if tower_data.life <= 0:
		# Nothing to do, stop execution
		return
	# Take the damage!
	if kind != "heal":
		tower_data.life -= (amount * (1+ (Globals.level * 0.05)))
	else:
		tower_data.life -= amount
		Globals.stat_heals -= amount
	# Are we dead yet?
	if tower_data.life <= 0:
		# We're dead bro!
		# TODO: Screams of agony, etc
		queue_free()
		return
	# We're still alive! Should this be our new target?
	if tower_data.behavior == "melee":
			# Is the kind of damage we took also melee?
			if kind == "melee":
				# Yea, Do we already have a target?
				if !is_instance_valid(target):
					# We don't have a valid target, update our target
					target = who
	# We're still alive! Should this be our new target?
	if tower_data.behavior == "arrow" || tower_data.behavior == "fireball":
			# Is the kind of damage we took also ranged?
			if kind == "ranged":
				# Yea, they're shooting as us! Is whoever shot at us still a valid instance?
				if !is_instance_valid(who):
					# They are, SHOOT EM BACK
					target = who
