extends Area2D

@export var heal_amount = 25.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.current_health < body.max_health:
			body.heal(heal_amount)
			
			#add sfx or animations here
			queue_free()
