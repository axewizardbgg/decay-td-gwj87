extends Node2D

# Expected to be set before _ready
var target: Node2D
var who: Node2D # Who shot this arrow
var damage: float

# Misc stuff to handle travelling in an arc
var last_target_position: Vector2 # In case the target dies mid-flight, we'll just land where there were
var start_position: Vector2 # Where we were fired from
var total_dist: float
var spd: float = 90 # Pixels per second
var time_to_hit: float = 0.5 # In seconds
var elapsed_time: float = 0 # In seconds

func _ready() -> void:
	if !is_instance_valid(target):
		# Nothing to do, no target and we haven't even started flying yet
		queue_free()
		return
	start_position = who.global_position
	last_target_position = target.global_position
	total_dist = start_position.distance_to(last_target_position)
	

func _process(delta: float) -> void:
	elapsed_time += delta
	# Is our target still valid?
	if is_instance_valid(target):
		# Yes, update our last pos
		last_target_position = target.global_position
		# Is our elapsed time over?
		if elapsed_time >= time_to_hit:
			# It is, deal the damage!
			if !is_instance_valid(who):
				who = null # Can throw an error if who is freed, so just set it to null if no longer valid
			target.take_damage(damage, "ranged", who)
			queue_free()
			return
	elif elapsed_time >= time_to_hit:
		# Our time is done, no target tho, so just destroy ourselves
		queue_free()
		return
	# Calculate our velocity
	var vel: Vector2 = (last_target_position-start_position) * (elapsed_time / time_to_hit)
	# To make it arc, we'll mess with the y axis
	if elapsed_time < (time_to_hit/2):
		vel.y -= (elapsed_time*100)
	else:
		vel.y -= ((time_to_hit/2) - (elapsed_time - (time_to_hit/2))) * 100
	global_position = start_position + vel
	# Angle our ourselves based on our vel
	$Sprite2D.rotation = (global_position-start_position).angle()
