extends Area2D
@export var ability_name : String = "can_jump"
@export_multiline var message : String = "Pulsa {key} para saltar"
@export var keyboard_texture: Texture2D
@export var controller_texture: Texture2D

func _on_body_entered(body):
	if body.name == "Player":
		
		#activate abilities
		if ability_name in GameManager.unlocked_abilities:
			GameManager.unlocked_abilities[ability_name] = true
			
			body.set(ability_name, true)
		
		# check if already seen
		if name in GameManager.tutorials_seen:
			body.set(ability_name, true)
			queue_free()
			return
		
		# if new add
		GameManager.tutorials_seen.append(name)
		
		body.set(ability_name, true) #search for var and change it
		show_message()

func show_message():
	var ui = get_tree().current_scene.find_child("TutorialUI", true, false)
	var label = ui.find_child("Label", true, false)
	var container = label.get_parent()
	
	get_tree().paused = true
	
	var current_texture = keyboard_texture
	if Input.get_connected_joypads().size() > 0:
		current_texture = controller_texture
	
	var old_tweens = get_tree().get_processed_tweens()
	for t in old_tweens:
		t.kill()
	
	var final_text = message
	if current_texture != null:
		var font_size = label.get_theme_font_size("normal_font_size")
		if font_size == 0: font_size = 48 #predefined parameter
		
		var img_tag = "[img valign=center height=" + str(font_size * 1.4) + "]" + current_texture.resource_path + "[/img]"
		final_text = message.replace("{key}", img_tag)
	
	label.text = "[center]" + final_text + "[/center]"
	
	label.visible_ratio = 0.0
	container.modulate.a = 1.0
	label.modulate.a = 1.0
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(label, "visible_ratio", 1.0, 0.25).set_trans(Tween.TRANS_LINEAR)	
	
	await get_tree().create_timer(2, true, false, true).timeout
	
	var tween_out = create_tween()
	tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(container, "modulate:a", 0.0, 0.5)
	
	await tween_out.finished
	get_tree().paused = false
	queue_free()
