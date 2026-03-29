extends Node2D


@export var caja_scene: PackedScene 
@export var carrito: Node2D         
@export var spawn_timer: Timer      

@export_group("rain")
@export var height: float = 600.0        
@export var horizontal_range: float = 150.0 
@export var rain: float = 0.5      

func _ready() -> void:
	if spawn_timer:
		spawn_timer.wait_time = rain
		spawn_timer.one_shot = false 
		
		if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
			spawn_timer.timeout.connect(_on_spawn_timer_timeout)



func start_rain() -> void:
	if spawn_timer and spawn_timer.is_stopped():
		spawn_timer.start()

func stop_rain() -> void:
	if spawn_timer and not spawn_timer.is_stopped():
		spawn_timer.stop()



func _on_spawn_timer_timeout() -> void:
	if not caja_scene or not carrito: return
	
	#variety
	var spawn_pos: Vector2
	var shoot_mode = randi() % 3
	var player = get_tree().get_first_node_in_group("player")
	
	var extra_force = 120.0
	var size_multiplier = randf_range(0.8, 1.2) # Random box sizes

	match shoot_mode:
		0: 
			if player:
				var lead_factor = player.velocity.x * 0.2
				spawn_pos = Vector2(player.global_position.x + lead_factor, carrito.global_position.y - height)
				extra_force = 250.0 
			else:
				spawn_pos = Vector2(carrito.global_position.x, carrito.global_position.y - height)

		1: 
			var offset_x = randf_range(-horizontal_range * 1.2, horizontal_range * 1.2)
			spawn_pos = Vector2(carrito.global_position.x + offset_x, carrito.global_position.y - height)
			extra_force = 100.0

		2: 
			var side = 1 if randf() > 0.5 else -1
			spawn_pos = Vector2(carrito.global_position.x + (horizontal_range * side), carrito.global_position.y - height)
			size_multiplier = 1.6
			extra_force = 50.0

	var new_box = caja_scene.instantiate()
	get_tree().current_scene.add_child(new_box)
	new_box.global_position = spawn_pos
	
	if new_box is RigidBody2D:
		# random size
		new_box.scale = Vector2(size_multiplier, size_multiplier)
		
		new_box.mass = size_multiplier 
		
		new_box.rotation = randf_range(0, 360)
		
		var chaos_x = randf_range(-40, 40)
		new_box.apply_central_impulse(Vector2(chaos_x, extra_force))
		
		new_box.angular_velocity = randf_range(-15, 15)
