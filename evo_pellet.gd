class_name EvoPellet
extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Alien:
		var alien = body
		#alien.pick_up_evopellet()
		pass
	queue_free()
