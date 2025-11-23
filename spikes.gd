extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	# Is the other area owner a valid instance?
	if !is_instance_valid(area.owner):
		# No, do nothing
		return
	# Is the other area owner a Tower?
	if !area.owner.is_in_group("towers"):
		# No, do nothing
		return
	# It is, delete that bastard, they got too close!
	area.owner.queue_free()
