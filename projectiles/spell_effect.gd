extends AnimatedSprite2D

# expected to be set before _ready
var animation_name: String = "default"
var spd: float = 1

func _ready() -> void:
	# Play the specified animation
	play(animation_name)
	# Some animations we want to play faster
	if animation_name == "swipe":
		spd = 2

func _process(delta: float) -> void:
	# Fade out
	modulate.a -= (delta * spd)
	if modulate.a <= 0:
		queue_free()
