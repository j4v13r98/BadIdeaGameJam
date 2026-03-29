extends CharacterBody2D

#Switches
@export var can_jump: bool = false
@export var can_double_jump: bool = false
@export var can_dash: bool = false
@export var can_ledge_grab: bool = false
var is_dead: bool = false

@export var max_health = 100.0 
@export var max_speed = 300.0
@export var jump_velocity  = -400.0
@export var max_jumps = 1
@export var jump_buffer_time = 0.1  #range to remember "jump" pressed
@export var coyote_time = 0.15 #seconds u can jump after walked off a ledge
@export var acceleration = 3600.0 #how fast u reach max_speed
@export var friction: float = 2000.0 #how fast u stop
@export var dash_speed = 800.0
@export var dash_duration = 0.2
@export var dash_cooldown = 0.5
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
var ledge_grab_cooldown = 0.0

@onready var ledge_ray_top: RayCast2D = $LedgeRayTop
@onready var ledge_ray_bottom: RayCast2D = $LedgeRayBottom
@onready var current_health = max_health

#core
func _ready() -> void:
	
	if GameManager.last_checkpoint_pos != Vector2.ZERO: #Check for checkpoints
		global_position = GameManager.last_checkpoint_pos
	else:
		GameManager.last_checkpoint_pos = global_position
	
	#setting abilities
	if not can_jump: 
		can_jump = GameManager.unlocked_abilities["can_jump"]
	
	if not can_double_jump: 
		can_double_jump = GameManager.unlocked_abilities["can_double_jump"]
		
	if not can_dash: 
		can_dash = GameManager.unlocked_abilities["can_dash"]
		
	if not can_ledge_grab: 
		can_ledge_grab = GameManager.unlocked_abilities["can_ledge_grab"]

func _physics_process(delta: float) -> void:
	update_timers(delta)
	update_raycasts()
	
	if is_on_ledge:
		handle_ledge_logic()
	elif is_dashing:
		handle_dash_logic(delta)
	else:
		if can_dash:
			check_dash_input()
		apply_gravity(delta)
		handle_jump()
		handle_horizontal_movement(delta)
		
		if can_ledge_grab == true:
			check_for_ledge()
		else:
			is_on_ledge = false
	
	move_and_slide()

# FUNCTIONS
func update_timers(delta):
	dash_cooldown_timer -= delta
	buffer_timer -= delta
	if ledge_grab_cooldown > 0:
		ledge_grab_cooldown -= delta
	
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

func handle_jump():
	if Input.is_action_just_pressed("jump") and can_jump:
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
		dash_dir = facing_direction #get last direction
	velocity.x = dash_dir * dash_speed
	velocity.y = 0 # cancel vertical movement

func handle_dash_logic(delta):
	dash_timer -= delta
	
	if Input.is_action_pressed("move_down"):
		cancel_dash()
		velocity.y = 200 #dive
		return
	
	var dash_dir = sign(velocity.x)
	velocity.x = dash_dir * dash_speed
	velocity.y = 0
	
	if dash_timer <= 0:
		is_dashing = false
		cancel_dash()

func cancel_dash():
	is_dashing = false
	dash_timer = 0
	velocity.x = 0   #hard brake

func handle_horizontal_movement(delta):
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	# Always pushing velocity toward the direction
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	if direction != 0:
		facing_direction = sign(direction) #remember last direction

func update_raycasts():
	var look_dist = 35.0 * facing_direction
	ledge_ray_top.target_position.x = look_dist
	ledge_ray_bottom.target_position.x = look_dist
	
func check_for_ledge():
	if not is_on_floor() and ledge_grab_cooldown <= 0:
		if ledge_ray_bottom.is_colliding() and not ledge_ray_top.is_colliding():
			var direction = Input.get_axis("move_left", "move_right")
			if direction == facing_direction:
				enter_ledge()

func enter_ledge():
	is_on_ledge = true
	velocity = Vector2.ZERO # Stop all movement
	jumpings = 0          # Refresh jumps for a ledge jump

func handle_ledge_logic():
	#jump off ledge
	if Input.is_action_just_pressed("jump"):
		is_on_ledge = false
		ledge_grab_cooldown = 0.2
		velocity.y = ledge_jump_velocity
		velocity.x = -facing_direction * ledge_jump_pushback 
		return

	#let go
	var dir = Input.get_axis("move_left", "move_right")
	if dir != facing_direction:
		is_on_ledge = false
		ledge_grab_cooldown = 0.2
		

func take_damage(amount:float):
	if is_dead:
		return
	
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	print("Health: ", current_health, "%")
	
	if current_health <= 0:
		is_dead = true
		die()

func heal(amount:float):
	if is_dead:
		return
	
	current_health += amount
	current_health = clamp(current_health, 0, max_health)
	
	print("Health: ", current_health, "%")

func _update_state(): #waiting for carol's designs
	var health_percent = current_health / max_health
	$Sprite2D.modulate = Color(1.0, health_percent, health_percent)
	
func die():
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	await FadeLayer.fade_to_black()
	await get_tree().create_timer(0.5).timeout
	get_tree().call_deferred("reload_current_scene")
	await get_tree().process_frame
	FadeLayer.fade_in() 
