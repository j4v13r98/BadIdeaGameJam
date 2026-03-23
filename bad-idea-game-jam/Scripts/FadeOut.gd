extends CanvasLayer

func _ready() -> void:
	fade_in()

func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, 0.4)

func fade_to_black():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 0.8) #Fade out animation
	await tween.finished
	return true
