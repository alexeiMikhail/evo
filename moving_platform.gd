extends Node2D

# tween variables
var tween = create_tween()
@export var platform_time: float = 3.0

@onready var platform_body = $platform_body
# Referenced within the stage. Has to be set as a child of the platform in the stage scene
@onready var move_point = $move_point

func _ready() -> void:
	# Queues up two tween animations into our one tween object, then sets them to be looped forever
	# Moves from starting point to the GLOBAL position of the in-scene point
	tween.tween_property(platform_body, "global_position", move_point.global_position, platform_time)
	# Moves from the in-scene point back to the ORIGINAL ORIGIN of this platform.
	tween.tween_property(platform_body, "global_position", self.global_position, platform_time)
	tween.set_loops()
	# We are only moving the platform's body, but not the origin point of the platform's scene.
	# Global position is important, because the origin position of this scene is (0,0) while in another 
	# scene its relative (or global) position is where we want to go.
