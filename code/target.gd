extends Node3D

@onready var sprite = $Sprite3D
@onready var player = $"../../Player"

var shrink_speed = 2

func _ready():
	if global_position == player.global_position: 	#global_position.distance_to(player.global_position) < 0.1:
			player.hurt()

func _process(delta: float) -> void:
	scale.x -= shrink_speed * delta
	scale.z -= shrink_speed * delta
	if scale.x <= 0:
		queue_free()
