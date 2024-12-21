class_name Alien
extends CharacterBody2D

@onready var change_timer: Timer = %ChangeTimer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var label: Label = %Label
@onready var dash_timer: Timer = %DashTimer

enum States {RUN, FLY, SWIM, COUNT}
@export var state: States

var in_water: bool = false
var is_dashing: bool = false
var dash_direction: int = 1


const DASH_SPEED = 800.0
const SPEED = 500.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	progress_bar.max_value = change_timer.wait_time
	label.text = States.keys()[state]


func _process(_delta: float) -> void:
	progress_bar.value = change_timer.time_left


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dash") and not is_dashing:
		initiate_dash()
	if state == States.SWIM:
		swim(delta)
	if state == States.FLY:
		fly(delta)
	if state == States.RUN:
		run(delta)
	if is_dashing:
		velocity.x = DASH_SPEED * dash_direction
	move_and_slide()


func change_state():
	state = (state + 1) % States.COUNT
	label.text = States.keys()[state]

func run(delta):
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Early return so as not to change direction during a dash
	if is_dashing:
		return 
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)



func swim(delta):
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and in_water:
		velocity.y = JUMP_VELOCITY
	
	# Early return so as not to change direction during a dash
	if is_dashing:
		return 
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)



func fly(delta):
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and not in_water:
		velocity.y = JUMP_VELOCITY
	
	# Early return so as not to change direction during a dash
	if is_dashing:
		return 
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction and not is_dashing:
		velocity.x = direction * SPEED
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func initiate_dash():
	velocity.y = 0
	is_dashing = true
	dash_timer.start()
	if sprite_2d.flip_h:
		dash_direction = -1
	else:
		dash_direction = 1
		

func _on_dash_timer_timeout() -> void:
	is_dashing = false
