extends Node2D

signal place_tower(tower: String)

# What tower are we placing?
var selected_tower: String = "res://resources/towers/Zombie.tres"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_tower"):
		emit_signal("place_tower", selected_tower)
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
