extends Area2D

@export var key_wall: Area2D

func _on_body_entered(body):
	if body is Alien:
		key_wall.queue_free()
		queue_free()
