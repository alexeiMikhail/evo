class_name Alien
extends CharacterBody2D

@onready var change_timer: Timer = %ChangeTimer
@onready var progress_bar: ProgressBar = %ProgressBar



const SPEED = 500.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	progress_bar.max_value = change_timer.wait_time
	print(progress_bar.max_value)

func _process(delta: float) -> void:
	progress_bar.value = change_timer.time_left
	print(progress_bar.value, progress_bar.max_value)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
