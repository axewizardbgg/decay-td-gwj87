extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _process(delta: float) -> void:
	# Update health bar
	var pc: float = (Globals.lives / 100) * 100
	$ProgressBar.value = pc
