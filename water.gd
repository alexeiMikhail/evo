extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Alien:
		var alien: Alien = body
		alien.in_water = true
		alien.was_in_water = false
		alien.slow_on_water_entry()


func _on_body_exited(body: Node2D) -> void:
	if body is Alien:
		var alien: Alien = body
		alien.in_water = false
		alien.was_in_water = true
