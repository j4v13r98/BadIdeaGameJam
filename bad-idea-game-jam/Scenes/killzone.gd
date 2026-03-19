extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("you died")
		body.set_physics_process(false)
