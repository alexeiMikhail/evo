class_name Alien
extends CharacterBody2D

@onready var change_timer: Timer = %ChangeTimer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var label: Label = %Label
@onready var dash_timer: Timer = %DashTimer
@onready var coyote_timer: Timer = %CoyoteTimer

enum States {RUN, FLY, SWIM, COUNT}
@export var state: States

var in_water: bool = false
var is_dashing: bool = false
var dash_direction: int = 1
var holding_jump: bool = false
var current_dashes: int = 0
var was_in_water: bool = false
var mario_swim_speed_modifier: float = 0.3

const DASH_COUNT_ALLOWED: int = 1
const DASH_SPEED = 800.0
const SPEED = 400.0
const JUMP_VELOCITY = -500.0
const X_ACCELERATION = 25

func _ready() -> void:
	progress_bar.max_value = change_timer.wait_time
	label.text = States.keys()[state]


func _process(_delta: float) -> void:
	progress_bar.value = change_timer.time_left

func _physics_process(delta: float) -> void:
	handle_dash_input()
	if state == States.SWIM:
		swim(delta)
	if state == States.FLY:
		fly(delta)
	if state == States.RUN:
		run(delta)
	if is_dashing:
		velocity.x = DASH_SPEED * dash_direction
	
	var was_on_floor: bool = is_on_floor()
	
	# Reset dash counter after a collision
	if move_and_slide():
		current_dashes = 0
		was_in_water = false
	
	if was_on_floor and not is_on_floor():
		coyote_timer.start()


func change_state():
	@warning_ignore("int_as_enum_without_cast")
	state = (state + 1) % States.COUNT
	label.text = States.keys()[state]

func run(delta):
	# Dashing takes precedence over run script
	if is_dashing:
		return
	
	if in_water:
		mario_swim(delta)
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Maintain x momentum when jumping from water
	if was_in_water:
		handle_directional_input(mario_swim_speed_modifier)
		return

	handle_jump_input()
	handle_directional_input()


func swim(delta):
	pass


func mario_swim(delta):
	var modifier: float = mario_swim_speed_modifier
	
	# Don't swim while dashing, let the dash take precedence
	if is_dashing:
		return
	
	# Add the gravity.
	if not is_on_ceiling():
		velocity -= get_gravity() * modifier * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and in_water:
		jump(-modifier)
	
	handle_directional_input(modifier)


func fly(delta):
	# Add the gravity.
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and not in_water:
		jump()
	
	# Do not change direction during a dash
	if not is_dashing:
		handle_directional_input()


func initiate_dash():
	current_dashes += 1
	velocity.y = 0
	is_dashing = true
	dash_timer.start()
	if sprite_2d.flip_h:
		dash_direction = -1
	else:
		dash_direction = 1
		

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	if Input.is_action_pressed("jump") and is_on_floor():
		jump()

func jump(modifier: float = 1.0):
	velocity.y += JUMP_VELOCITY * modifier

func jump_cut():
	if velocity.y < -100:
		velocity.y = -100

func handle_jump_input():
	var floored: bool = is_on_floor() or not coyote_timer.is_stopped()
	if Input.is_action_just_pressed("jump") and floored and not is_dashing:
		jump()
	
	if Input.is_action_just_released("jump"):
		jump_cut()

func handle_directional_input(modifier: float = 1.0):
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED * modifier, X_ACCELERATION)
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, X_ACCELERATION)


func handle_dash_input():
	if Input.is_action_just_pressed("dash") and not is_dashing and current_dashes < DASH_COUNT_ALLOWED:
		initiate_dash()


func slow_on_water_entry():
	if velocity.y > 200:
		velocity.y = 200
