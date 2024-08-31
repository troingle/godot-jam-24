extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		if name == "Main":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/main.tscn")
