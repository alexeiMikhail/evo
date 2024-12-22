extends Node2D

# Variables to control the swing
var swing_speed: float = 2.0  # Speed of the swing
var swing_amplitude = 90  # Maximum angle (in radians)

var tween = create_tween()

func _ready() -> void:
	pass


#func swing():
	#tween.tween_property(self, "rotation_degrees", swing_amplitude, 1)
	#swing_amplitude = -swing_amplitude
