extends Node2D

# TODO: testing this out
var spawn_timer: float = 0
var boss1_dead: bool = false
var boss2_dead: bool = false
var res: Array[TowerData] = [
	preload("res://resources/towers/Zombie.tres"),
	preload("res://resources/towers/Skele.tres"),
	preload("res://resources/towers/SkeleArcher.tres"),
	preload("res://resources/towers/PurpleMage.tres"),
	preload("res://resources/towers/BlackMage.tres")
]

var overlay_acknowledged: bool = false

func _ready() -> void:
	Globals.unit_selected.connect(_unit_selected)
	_update_tooltips()
	_unit_selected()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_tutorial"):
		if $CanvasLayer/Control/TutorialOverlay.visible:
			$CanvasLayer/Control/TutorialOverlay.visible = false
			overlay_acknowledged = true
		else:
			$CanvasLayer/Control/TutorialOverlay.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_tower"):
		_place_tower(Globals.selected_tower)

func _process(delta: float) -> void:
	# Have we failed?
	if Globals.lives <= 0:
		# We have failed! Game over
		var e: Control = load("res://ui/End.tscn").instantiate()
		e.victory = false
		get_tree().root.add_child(e)
		queue_free()
	
	# Are we out of guys?
	if get_tree().get_node_count_in_group("towers") <= 0:
		# We are, do we have enough resources to spawn any?
		if !_can_afford(res[0]):
			# We don't, end the game
			var e: Control = load("res://ui/End.tscn").instantiate()
			e.victory = false
			get_tree().root.add_child(e)
			queue_free()
	# Spawning
	if overlay_acknowledged:
		spawn_timer -= delta
	if spawn_timer <= 0:
		# Stop spawning enemies at lvl 50!
		if Globals.level >= 50:
			spawn_timer = 10000
			return
		# Spawn a creep!
		spawn_timer = Spawn.spawn_creep($Path2D)
	
	# Update UI
	var pc_exp: float = 0
	if Globals.experience > 0:
		pc_exp = (Globals.experience / Globals.exp_to_level) * 100
	$CanvasLayer/Control/ProgressBar.value = pc_exp
	$CanvasLayer/Control/RP/VBC/HBC/Bones.text = str(Globals.bones)
	$CanvasLayer/Control/RP/VBC/HBC2/Steel.text = str(Globals.steel)
	$CanvasLayer/Control/RP/VBC/HBC3/Magic.text = str(Globals.magic)
	$CanvasLayer/Control/Level.text = "Level: "+str(Globals.level)
	
	# This is a terrible way of doing it but whatever, I'm tired af
	if _can_afford(res[0]):
		$CanvasLayer/Control/RP/VBC/Zombie.disabled = false
	else:
		$CanvasLayer/Control/RP/VBC/Zombie.disabled = true
	if _can_afford(res[1]):
		$CanvasLayer/Control/RP/VBC/Skele.disabled = false
	else:
		$CanvasLayer/Control/RP/VBC/Skele.disabled = true
	if _can_afford(res[2]):
		$CanvasLayer/Control/RP/VBC/SkeleArcher.disabled = false
	else:
		$CanvasLayer/Control/RP/VBC/SkeleArcher.disabled = true
	if _can_afford(res[3]):
		$CanvasLayer/Control/RP/VBC/Warlock.disabled = false
	else:
		$CanvasLayer/Control/RP/VBC/Warlock.disabled = true
	if _can_afford(res[4]):
		$CanvasLayer/Control/RP/VBC/DemiLich.disabled = false
	else:
		$CanvasLayer/Control/RP/VBC/DemiLich.disabled = true
	
	# Handle level up
	if Globals.experience >= Globals.exp_to_level:
		Globals.level += 1
		Globals.experience -= Globals.exp_to_level
		Globals.exp_to_level = Globals.base_exp * (1 + (.10 * Globals.level))
		# Update button tooltips
		_update_tooltips()
		# Add the Level Up screen
		var ui: Control = load("res://ui/levelup.tscn").instantiate()
		$CanvasLayer.add_child(ui)
		# Are we level 100?
		if Globals.level == 50:
			# Spawn the boss!
			var b1: PathFollow2D = load("res://Creep.tscn").instantiate()
			b1.creep_data = load("res://resources/creeps/Boss1.tres")
			b1.scale = Vector2(3,3)
			$Path2D.add_child(b1)
			b1.creep_death.connect(_boss_dead.bind(1))
			Audio.play_standalone_sound("res://sounds/i require only.mp3")
			# Add a timer so we can summon the second one
			get_tree().create_timer(7, false).timeout.connect(_spawn_boss2)
		get_tree().paused = true

func _boss_dead(b: int):
	if b == 1:
		boss1_dead = true
	else:
		boss2_dead = true
	
	if boss1_dead && boss2_dead:
		# Game over
		var e: Control = load("res://ui/End.tscn").instantiate()
		e.victory = true
		get_tree().root.add_child(e)
		queue_free()

func _spawn_boss2():
	var b2: PathFollow2D = load("res://Creep.tscn").instantiate()
	b2.creep_data = load("res://resources/creeps/Boss2.tres")
	b2.scale = Vector2(3,3)
	$Path2D.add_child(b2)
	b2.creep_death.connect(_boss_dead.bind(2))
	Audio.play_standalone_sound("res://sounds/you cant handle.mp3")

func _update_tooltips() -> void:
	_update_tooltip(res[0], $CanvasLayer/Control/RP/VBC/Zombie)
	_update_tooltip(res[1], $CanvasLayer/Control/RP/VBC/Skele)
	_update_tooltip(res[2], $CanvasLayer/Control/RP/VBC/SkeleArcher)
	_update_tooltip(res[3], $CanvasLayer/Control/RP/VBC/Warlock)
	_update_tooltip(res[4], $CanvasLayer/Control/RP/VBC/DemiLich)
	

func _update_tooltip(td: TowerData, btn: Button) -> void:
	var b_cost: int = round(td.required_resources.bones * (1 + ((Globals.level - 1) * 0.01)))
	var s_cost: int = round(td.required_resources.steel * (1 + ((Globals.level - 1) * 0.01)))
	var m_cost: int = round(td.required_resources.magic * (1 + ((Globals.level - 1) * 0.01)))
	var t: String = td.title+"\n\nHP: "+str(round(td.life * Globals.mod_life))+"\n"
	t += "Move Speed: "+str(round(td.spd))+"\n"
	t += "Damage: "+str(round(td.damage * Globals.mod_damage))+"\n"
	t += "Atk Cooldown: "+str(snappedf(td.action_interval * Globals.mod_action_interval, 0.01))+"sec\n"
	match td.behavior:
		"melee":
			t += "Range: 32 (Melee)\n"
		_:
			t += "Range: 128\n"
	t += "\nCost:\n - Bones: "+str(b_cost)+"\n - Steel: "+str(s_cost)+"\n - Magic: "+str(m_cost)+"\n"
	
	btn.tooltip_text = t

func _can_afford(tower_data: TowerData) -> bool:
	var affordable: bool = true
	var b_cost: int = round(tower_data.required_resources.bones * (1 + ((Globals.level - 1) * 0.01)))
	var s_cost: int = round(tower_data.required_resources.steel * (1 + ((Globals.level - 1) * 0.01)))
	var m_cost: int = round(tower_data.required_resources.magic * (1 + ((Globals.level - 1) * 0.01)))
	if tower_data.required_resources.bones > 0:
		if Globals.bones < b_cost:
			affordable = false
	if tower_data.required_resources.steel > 0:
		if Globals.steel < s_cost:
			affordable = false
	if tower_data.required_resources.magic > 0:
		if Globals.magic < m_cost:
			affordable = false
	# Return the result
	return affordable

func _place_tower(path: String) -> void:
	# First, let's determine if we can indeed place it
	var tower_data: TowerData = load(path)
	var placeable: bool = true
	var b_cost: int = round(tower_data.required_resources.bones * (1 + ((Globals.level - 1) * 0.01)))
	var s_cost: int = round(tower_data.required_resources.steel * (1 + ((Globals.level - 1) * 0.01)))
	var m_cost: int = round(tower_data.required_resources.magic * (1 + ((Globals.level - 1) * 0.01)))
	if tower_data.required_resources.bones > 0:
		if Globals.bones < b_cost:
			placeable = false
	if tower_data.required_resources.steel > 0:
		if Globals.steel < s_cost:
			placeable = false
	if tower_data.required_resources.magic > 0:
		if Globals.magic < m_cost:
			placeable = false
	# Can we place it?
	if !placeable:
		# No, stop execution, nothing to do here
		return
	# We can, do eet!
	var t: Node2D = load("res://Tower.tscn").instantiate()
	t.tower_data = tower_data.duplicate(true)
	add_child(t)
	t.global_position = get_global_mouse_position()
	# Subtract the resources
	Globals.bones -= b_cost
	Globals.steel -= s_cost
	Globals.magic -= m_cost
	# Add the spell effect
	var e: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
	t.add_child(e)
	# Also add one to the Necromancer too
	var e2: AnimatedSprite2D = load("res://projectiles/SpellEffect.tscn").instantiate()
	$Necromancer.add_child(e2)
	e2.scale = Vector2(2, 2)

# Signal connector function for when a unit is selected, either by clicking button or pressing key
func _unit_selected():
	# Determine which unit was selected, and have that button grab focus
	match Globals.selected_tower:
		"res://resources/towers/Zombie.tres":
			$CanvasLayer/Control/RP/VBC/Zombie.grab_focus()
		"res://resources/towers/Skele.tres":
			$CanvasLayer/Control/RP/VBC/Skele.grab_focus()
		"res://resources/towers/SkeleArcher.tres":
			$CanvasLayer/Control/RP/VBC/SkeleArcher.grab_focus()
		"res://resources/towers/PurpleMage.tres":
			$CanvasLayer/Control/RP/VBC/Warlock.grab_focus()
		"res://resources/towers/BlackMage.tres":
			$CanvasLayer/Control/RP/VBC/DemiLich.grab_focus()


func _on_zombie_pressed() -> void:
	Globals.selected_tower = "res://resources/towers/Zombie.tres"

func _on_skele_pressed() -> void:
	Globals.selected_tower = "res://resources/towers/Skele.tres"

func _on_skele_archer_pressed() -> void:
	Globals.selected_tower = "res://resources/towers/SkeleArcher.tres"

func _on_warlock_pressed() -> void:
	Globals.selected_tower = "res://resources/towers/PurpleMage.tres"

func _on_demi_lich_pressed() -> void:
	Globals.selected_tower = "res://resources/towers/BlackMage.tres"
