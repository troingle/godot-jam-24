extends Node3D

@export var speed = 0.9

@onready var player = $"../Player"

func _process(delta: float) -> void:
	global_rotation.y += 15 * delta
	
	if name == "Sawblade":
		if global_position.distance_to(player.global_position) < 0.35:
			player.hurt()
	else:
		if global_position.distance_to(player.global_position) < 0.55:
			player.hurt()
