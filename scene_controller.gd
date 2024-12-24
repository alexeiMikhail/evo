extends Node

@onready var animation_player = $AnimationPlayer

var advancing = false


func _ready():
	$AnimationPlayer/ColorRect.color.a = 0

func _restart():
	advancing = false
	animation_player.play("fade_in")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		var RELOAD = load("res://level_1.tscn").instantiate()
		RELOAD.visible = false
		add_child(RELOAD)
		$Level1.queue_free()
		RELOAD.visible = true
		animation_player.play("fade_out")
