extends Control


func _on_button_pressed() -> void:
	var m = load("res://main.tscn").instantiate()
	get_tree().root.add_child(m)
	queue_free()
