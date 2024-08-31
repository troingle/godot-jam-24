extends Node3D

@onready var player = $"../../Player"
@onready var game = $"../../GameManager"

func _process(delta):
	global_rotation.y += 5 * delta
	
	if game.phase == 4:
		visible = false
	elif player.global_position.distance_to(global_position) < 0.26:
		player.collect()
		queue_free()
