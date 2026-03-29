extends AnimatableBody2D

@export var speed: float = 200.0
@export var box_scene: PackedScene
@export var spawner: Node2D

var is_active: bool = false

# This refers to the PathFollow2D
@onready var path_follower = get_parent() 

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		print("player on platform")
		
		is_active = true 
		
		if spawner and spawner.has_method("start_rain"):
			spawner.start_rain()

func _physics_process(delta: float):
	if is_active and path_follower is PathFollow2D:
		path_follower.progress += speed * delta
		
		# Stop at the end
		if path_follower.progress_ratio >= 0.99:
			is_active = false
