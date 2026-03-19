extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity  = -400.0
var jumpings = 0 #number of jumps


func _physics_process(delta: float) -> void:
	# Gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump.
	if is_on_floor():
		jumpings = 0
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif jumpings < 1:
			velocity.y = jump_velocity * 0.7
			jumpings += 1

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
