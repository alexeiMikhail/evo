extends Sprite2D

func _on_area_2d_body_exited(body):
	$AudioStreamPlayer.play()
