extends Area2D

@export var ui_canvas: CanvasLayer
@export var restart_timer: Timer

func _ready() -> void:
	restart_timer.timeout.connect(_on_restart_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		show_finish_screen()

func show_finish_screen():
	ui_canvas.show()
	restart_timer.start()
	
	var spawner = get_tree().get_first_node_in_group("spawner")
	if spawner:
		spawner.stop_rain()

func _on_restart_timer_timeout():
	ui_canvas.hide()
	get_tree().reload_current_scene()
