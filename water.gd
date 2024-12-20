extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Alien:
		var alien: Alien = body
		alien.in_water = true


func _on_body_exited(body: Node2D) -> void:
	if body is Alien:
		var alien: Alien = body
		alien.in_water = false
