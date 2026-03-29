extends Area2D

@export var damage_amount: float = 20.0 # amount of damage
@export var is_on_touch: bool = true # damage by one touch
@export var damage_per_second: float = 10.0 # Damage per second

var player_inside: Node2D = null

func _ready() -> void:
	set_physics_process(not is_on_touch) #stop damage per second
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_on_touch:
			if body.has_method("take_damage"):
				body.take_damage(damage_amount)
		else:
			player_inside = body

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = null

func _physics_process(delta: float) -> void:
	if not is_on_touch and player_inside and player_inside.has_method("take_damage"):
		player_inside.take_damage(damage_per_second * delta)
