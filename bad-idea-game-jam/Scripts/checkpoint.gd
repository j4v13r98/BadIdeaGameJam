extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		print("he entered")
		GameManager.last_checkpoint_pos = global_position
