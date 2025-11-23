extends Node

var schedule: Array[Array] = [
	# 0
	[
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 3.0,
			"amount": 1
		}
	],
	# 1
	[
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 2.5,
			"amount": 5
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 3.0,
			"amount": 2
		}
	],
	# 2
	[
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 2.0,
			"amount": 3
		},
		{
			"path": "res://resources/creeps/Knight.tres",
			"interval": 3.0,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 2.0,
			"amount": 2
		}
	],
	# 3
	[
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 1.5,
			"amount": 3
		},
		{
			"path": "res://resources/creeps/Knight.tres",
			"interval": 2.0,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 2.0,
			"amount": 3
		},
		{
			"path": "res://resources/creeps/Priest.tres",
			"interval": 2.0,
			"amount": 3
		},
	],
	# 4
	[
		{
			"path": "res://resources/creeps/Knight.tres",
			"interval": 1.5,
			"amount": 2
		},
		{
			"path": "res://resources/creeps/Wizard.tres",
			"interval": 1.5,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 0.5,
			"amount": 4
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 1.5,
			"amount": 2
		},
		{
			"path": "res://resources/creeps/Priest.tres",
			"interval": 1.5,
			"amount": 1
		},
	],
	# 5
	[
		{
			"path": "res://resources/creeps/Paladin.tres",
			"interval": 2.0,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Knight.tres",
			"interval": 1.5,
			"amount": 4
		},
		{
			"path": "res://resources/creeps/Priest.tres",
			"interval": 1.5,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 1.5,
			"amount": 2
		},
		{
			"path": "res://resources/creeps/Wizard.tres",
			"interval": 2.5,
			"amount": 1
		},
	],
	# 6
	[
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 0.5,
			"amount": 10
		},
		{
			"path": "res://resources/creeps/Priest.tres",
			"interval": 0.5,
			"amount": 2
		},
		{
			"path": "res://resources/creeps/Paladin.tres",
			"interval": 4.0,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 0.5,
			"amount": 3
		},
	],
	# 7
	[
		{
			"path": "res://resources/creeps/Paladin.tres",
			"interval": 2.0,
			"amount": 3
		},
		{
			"path": "res://resources/creeps/Priest.tres",
			"interval": 0.5,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Wizard.tres",
			"interval": 0.5,
			"amount": 1
		},
		{
			"path": "res://resources/creeps/Knight.tres",
			"interval": 0.5,
			"amount": 10
		},
	],
	# 8
	[
		{
			"path": "res://resources/creeps/Paladin.tres",
			"interval": 0.5,
			"amount": 5
		},
		{
			"path": "res://resources/creeps/Priest.tres",
			"interval": 0.5,
			"amount": 3
		},
		{
			"path": "res://resources/creeps/Wizard.tres",
			"interval": 0.5,
			"amount": 2
		},
		{
			"path": "res://resources/creeps/Peasant.tres",
			"interval": 0.2,
			"amount": 15
		},
		{
			"path": "res://resources/creeps/Archer.tres",
			"interval": 0.3,
			"amount": 10
		},
	]
]

# Other spawner stuff
var current_interval: float = 3.0
var current_schedule: int = 0 # Corresponds to the numbers in the schedule, 0-8 atm
var current_iteration: int = 0 # Corresponds to the inner array of schedule
var current_count: int = 0 # Corresponds to the amount field in the innermost dictionary of schedule

# Spawns a creep according do the Schedule and makes it a child of the specified Path2D node
# Returns the interval to the next spawn
func spawn_creep(path2D: Path2D) -> float:
	# First, make sure we're on the right schedule
	# TODO: I know this is an absolute shit way of doing this, but it's midnight... ugh
	if Globals.level < 3:
		if current_schedule != 0:
			current_schedule = 0
			current_iteration = 0
			current_count = 0
	elif Globals.level < 6:
		if current_schedule != 1:
			current_schedule = 1
			current_iteration = 0
			current_count = 0
	elif Globals.level < 9:
		if current_schedule != 2:
			current_schedule = 2
			current_iteration = 0
			current_count = 0
	elif Globals.level < 12:
		if current_schedule != 3:
			current_schedule = 3
			current_iteration = 0
			current_count = 0
	elif Globals.level < 15:
		if current_schedule != 4:
			current_schedule = 4
			current_iteration = 0
			current_count = 0
	elif Globals.level < 18:
		if current_schedule != 5:
			current_schedule = 5
			current_iteration = 0
			current_count = 0
	elif Globals.level < 21:
		if current_schedule != 6:
			current_schedule = 6
			current_iteration = 0
			current_count = 0
	elif Globals.level < 24:
		if current_schedule != 7:
			current_schedule = 7
			current_iteration = 0
			current_count = 0
	else:
		if current_schedule != 8:
			current_schedule = 8
			current_iteration = 0
			current_count = 0

	# Instantiate a the creep_data resource
	var cd: CreepData = load(schedule[current_schedule][current_iteration].path).duplicate(true)
	# Get a creep ready
	var c: Node2D = load("res://Creep.tscn").instantiate()
	c.creep_data = cd
	# Add it to the scene
	path2D.add_child(c)
	
	# Now we handle determining the next iteration
	current_count += 1
	# Have we spawned the appropriate amount for this iteration?
	if current_count >= schedule[current_schedule][current_iteration].amount:
		# We have, next iteration within the schedule (if we can)
		var size: int = schedule[current_schedule].size()
		current_iteration += 1
		if (current_iteration) >= size:
			# End of iterations, reset the current iteration back to the first one (0)
			current_iteration = 0
			current_count = 0
			
	
	# Return the interval that should elapse before calling this method again
	var interval: float = schedule[current_schedule][current_iteration].interval * (1 - ((Globals.level * 0.01))) + (Globals.mod_spawn - 1)
	if interval <= 0.2:
		interval = 0.2
	return interval
