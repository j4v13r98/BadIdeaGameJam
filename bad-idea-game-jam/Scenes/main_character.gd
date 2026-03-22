extends CharacterBody2D

#Switches
@export var can_double_jump = true
@export var can_dash: bool = true
@export var can_ledge_grab: bool = true

@export var max_speed = 300.0
@export var jump_velocity  = -400.0
@export var max_jumps = 1
@export var jump_buffer_time = 0.1  #range to remember "jump" pressed
@export var coyote_time = 0.15 #seconds u can jump after walked off a ledge
@export var acceleration = 3600.0 #how fast u reach max_speed
@export var friction: float = 2000.0 #how fast u stop
@export var dash_speed = 800.0
@export var dash_duration = 0.2
@export var dash_cooldown = 1.0
@export var ledge_jump_velocity = -450.0 # Vertical boost from ledge
@export var ledge_jump_pushback = 200.0   # Horizontal push away from wall

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var is_dashing = false
var coyote_timer = 0.0
var jumpings = 0 #number of jumps
var buffer_timer = 0.0
var facing_direction = 1.0
var is_on_ledge = false

@onready var ledge_ray_top: RayCast2D = $LedgeRayTop
@onready var ledge_ray_bottom: RayCast2D = $LedgeRayBottom

#core
func _physics_process(delta: float) -> void:
	update_timers(delta)
	update_raycasts()
	
	if is_on_ledge:
		handle_ledge_logic()
	elif is_dashing:
		handle_dash_logic(delta)
	else:
		apply_gravity(delta)
		handle_jump()
		handle_horizontal_movement(delta)
		
		if can_ledge_grab:
			check_for_ledge()
	
	if can_dash:
		check_dash_input()
	
	move_and_slide()
	
# FUNCTIONS
func update_timers(delta):
	dash_timer -= delta
	dash_cooldown_timer -= delta
	buffer_timer -= delta
	
	if is_on_floor():
		coyote_timer = coyote_time # Refill coyote
		jumpings = 0               # Reset jump count
		is_on_ledge = false        #Reset ledge state on ground
	else:
		coyote_timer -= delta  

func apply_gravity(delta):
	if not is_on_floor():
		var multiplier = 1.0
		#Falling
		if velocity.y > 0: multiplier = 3.0
		#Short Hop
		elif not Input.is_action_pressed("jump"): multiplier = 2.0
		velocity += get_gravity() * delta * multiplier
		coyote_timer -= delta #Decrease coyote time in air

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		buffer_timer = jump_buffer_time
	if  buffer_timer > 0:
		if coyote_timer > 0: 
			execute_jump(false)
		elif can_double_jump and jumpings <= max_jumps:
			execute_jump(true)

func execute_jump(is_extra_jump):
	if is_extra_jump:
		velocity.y = jump_velocity * 0.8
	else:
		velocity.y = jump_velocity
	coyote_timer = 0.0
	buffer_timer = 0.0
	jumpings += 1

func check_dash_input():
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
		start_dash()

func start_dash():
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	var dash_dir:= Input.get_axis("move_left", "move_right")
	if dash_dir == 0:
		dash_dir = facing_direction #get las direction
	velocity.x = dash_dir * dash_speed
	velocity.y = 0 # cancel vertical movement

func handle_dash_logic(delta):
	if dash_timer <= 0:
		is_dashing = false
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_horizontal_movement(delta):
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	# Always pushing velocity toward the direction
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, 
		acceleration * delta)
	if direction != 0:
		facing_direction = sign(direction) #remember last direction

func update_raycasts():
	#Keeps the raycast the way the character is facing
	ledge_ray_top.target_position.x = (
		abs(ledge_ray_top.target_position.x) * facing_direction
		)
	ledge_ray_bottom.target_position.x = (
		 abs(ledge_ray_bottom.target_position.x) * facing_direction
		)
	ledge_ray_top.target_position.x = 35.0 * facing_direction
	ledge_ray_bottom.target_position.x = 35.0 * facing_direction

func check_for_ledge():
	if velocity.y >= 0 and not is_on_floor():
		if ledge_ray_bottom.is_colliding() and not ledge_ray_top.is_colliding():
			# Optional: Player must be holding towards the wall to grab
			var direction = Input.get_axis("move_left", "move_right")
			if direction == facing_direction:
				enter_ledge()

func enter_ledge():
	is_on_ledge = true
	velocity = Vector2.ZERO # Stop all movement
	jumpings = 0          # Refresh jumps for a ledge jump

func handle_ledge_logic():
	# 1. Jump off ledge
	if Input.is_action_just_pressed("jump"):
		is_on_ledge = false
		velocity.y = ledge_jump_velocity
		velocity.x = -facing_direction * ledge_jump_pushback 
		return

	# 2. Let go (Press Down or away from wall)
	var dir = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("move_down") or (dir != 0 and dir != facing_direction):
		is_on_ledge = false
