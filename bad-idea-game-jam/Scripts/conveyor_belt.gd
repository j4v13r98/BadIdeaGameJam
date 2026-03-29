extends Area2D

@export var belt_speed: float = 200.0 

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("get") and body.get("is_dashing"): 
			continue
			
		if body is CharacterBody2D:
			body.move_and_collide(Vector2(-belt_speed * delta, 0))

		elif body is RigidBody2D:
			body.linear_velocity.x = -belt_speed
