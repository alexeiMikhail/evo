class_name Alien
extends CharacterBody2D

@onready var change_timer: Timer = %ChangeTimer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var label: Label = %Label
@onready var dash_timer: Timer = %DashTimer
@onready var coyote_timer: Timer = %CoyoteTimer

enum States {RUN, SWIM, FLY, COUNT}
@export var state: States

var in_water: bool = false
var is_dashing: bool = false
#var dash_direction: int = 1
var dash_direction: Vector2
var holding_jump: bool = false
var current_dashes: int = 0
var was_in_water: bool = false
var mario_swim_speed_modifier: float = 0.3

@export var DASH_COUNT_ALLOWED: int = 1
@export var DASH_SPEED: float = 800.0
@export var RUN_SPEED: float = 400.0
@export var JUMP_VELOCITY: float = -500.0
@export var X_ACCELERATION: float = 25
@export var SWIM_SPEED: float = 5000.0
@export var ROTATION_SPEED: float = 5.0
@export var HOP_SPEED: float = 1000.0
@export var GLIDE_MODIFIER: float = 0.75


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
		velocity = DASH_SPEED * dash_direction
	
	var was_on_floor: bool = is_on_floor()
	
	# Reset dash counter after a collision or when swimming in SWIM mode
	if move_and_slide() or (in_water and state == States.SWIM):
		current_dashes = 0
		was_in_water = false
	
	if was_on_floor and not is_on_floor():
		coyote_timer.start()


# TODO update so that states don't loop
func change_state(looping: bool = false):
	@warning_ignore("int_as_enum_without_cast")
	# Resets rotation to 0 when beginning run. Avoids running rotated
	if state == States.SWIM:
		self.rotation = 0
	# Resets flip_h to avoid swimming backwards
	elif state == States.FLY:
		sprite_2d.flip_h = false
	
	if state + 1 < States.COUNT or looping:
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
	
	# Maintain x-momentum when jumping from water
	if was_in_water:
		handle_directional_input(mario_swim_speed_modifier)
		return

	handle_jump_input()
	handle_directional_input()


func swim(delta):
	if not in_water:
		fish_out_of_water(delta)
		return
	
	var rotation_direction = Input.get_axis("rotate_left", "rotate_right")
	rotation += rotation_direction * ROTATION_SPEED * delta
	
	var player_direction = Input.get_axis("swim_backward", "swim_forward")
	velocity = player_direction * SWIM_SPEED * transform.x


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
	var is_gliding: bool = Input.is_action_pressed("jump") and velocity.y > 0 and not in_water
	
	# Add the gravity.
	if not is_on_floor() and not is_dashing and not in_water and not is_gliding:
		velocity += get_gravity() * delta
	
	if in_water:
		velocity -= get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and not in_water:
		jump()
	
	# Do not change direction during a dash
	if not is_dashing:
		if not in_water and not is_on_floor() and not is_gliding:
			handle_directional_input()
		if in_water or is_on_floor():
			handle_directional_input(0.3)
		if is_gliding:
			handle_directional_input(GLIDE_MODIFIER)
	
	if is_gliding:
		velocity.y = move_toward(velocity.y, RUN_SPEED * GLIDE_MODIFIER, get_gravity().y * delta) 


func initiate_dash():
	# Adds dashes to the counter, asserting later that the player may not dash again until dashes are clear
	current_dashes += 1
	velocity.y = 0
	is_dashing = true
	dash_timer.start()
	# Non-swim dash goes straight horizontally in faced direction
	if state == States.RUN or state == States.FLY:
		if sprite_2d.flip_h:
			dash_direction = Vector2(-1, 0)
		else:
			dash_direction = Vector2(1, 0)
	# Swim dash follows faced direction
	elif state == States.SWIM:
		dash_direction = Vector2(1,0).rotated(self.rotation)

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	if Input.is_action_pressed("jump") and is_on_floor() or not coyote_timer.is_stopped():
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
		velocity.x = move_toward(velocity.x, direction * RUN_SPEED * modifier, X_ACCELERATION)
		sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, X_ACCELERATION)


func handle_dash_input():
	if Input.is_action_just_pressed("dash") and not is_dashing and current_dashes < DASH_COUNT_ALLOWED:
		initiate_dash()


func slow_on_water_entry():
	if velocity.y > 200:
		velocity.y = 200

func fish_out_of_water(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var rotation_direction = Input.get_axis("rotate_left", "rotate_right")
	rotation += rotation_direction * ROTATION_SPEED * delta
	
	var player_direction = Input.get_axis("swim_backward", "swim_forward")
	
	# Out of water, player has tiny jumps in faced direction
	if is_on_floor() and player_direction:
		velocity = player_direction * HOP_SPEED * transform.x
		velocity.y -= HOP_SPEED / 10
	
	if not player_direction:
		pass


# TODO respawn at last checkpoint
# TODO add some checkpoints to level 1
# TODO add kill-zone scene (or maybe a detection area on the player?)
func die():
	print("dead")
	pass


func pick_up_evopellet():
	change_state()


func got_spiked(_body: Node2D) -> void:
	die()
