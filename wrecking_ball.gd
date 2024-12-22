extends Node2D

@onready var line: Line2D = %wrecking_line
@onready var ball = %placeholderBall

# tween variables
var tween = create_tween()
var swing_speed: float = 1.7  # Speed of the swing
var swing_degree: int = 90  # Maximum angle (in radians)

func _ready() -> void:
	# Sets tween's eases, the rates it speeds and slows its process
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	# Queues up two tween animations into our one tween object, then sets them to be looped forever
	tween.tween_property(self, "rotation_degrees", -swing_degree, swing_speed)
	tween.tween_property(self, "rotation_degrees", swing_degree, swing_speed)
	tween.set_loops()
	# Draws initial line between wrecking ball base and the ball itself
	line.add_point(Vector2.ZERO, 0)
	line.add_point(Vector2(ball.position), 1)


func _process(float) -> void:
	# Updates line to stay connected to ball
	line.set_point_position(1, Vector2(ball.position))


func _on_area_2d_body_entered(body):
	# Kills player if they touch the wrecking ball
	if body is Alien:
		var alien: Alien = body
		alien.die()
