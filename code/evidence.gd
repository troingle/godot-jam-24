extends Node3D

@onready var player = $"../../Player"

func _process(delta):
	global_rotation.y += 5 * delta
	
	if player.global_position.distance_to(global_position) < 0.26:
		player.collect()
		queue_free()
