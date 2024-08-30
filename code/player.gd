extends CharacterBody3D

@onready var root = $".."

@onready var sprite = $Parent/Sprite3D
@onready var wobble = $Wobble
@onready var particles = $CPUParticles3D

@onready var evidence_obj = load("res://scenes/evidence.tscn")
@onready var parent = $"../EvidenceParent"

@onready var heart_obj = load("res://scenes/heart.tscn")
@onready var heart_parent = $"../HeartParent"

@onready var game = $"../GameManager"

const SPEED = 2.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var side = 1
var rng = RandomNumberGenerator.new()

var hp = 3

func _ready():
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		wobble.play("wobble")
		particles.emitting = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		wobble.play("RESET")
		particles.emitting = false
		
	if hp == 2:
		$"../CanvasLayer/Heart3".visible = false
	if hp == 1:
		$"../CanvasLayer/Heart2".visible = false
	if hp == 0:
		$"../CanvasLayer/Heart".visible = false
		
	if Input.is_action_pressed("right"):
		particles.direction.x = 1
		particles.direction.z = 0
	if Input.is_action_pressed("left"):
		particles.direction.x = -1
		particles.direction.z = 0
	if Input.is_action_pressed("down"):
		sprite.texture = load("res://art/player_front.png")
		particles.direction.z = 1
		particles.direction.x = 0
	elif Input.is_action_pressed("up"):
		sprite.texture = load("res://art/player_back.png")
		particles.direction.z = -1
		particles.direction.x = 0
		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	move_and_slide()
	
func collect():
	game.score += 1
	
	var evidence = evidence_obj.instantiate()
	parent.global_position.x = rng.randf_range(0.3, 1.75) * side
	parent.global_position.z = rng.randf_range(-0.26, 2)
	parent.add_child(evidence)
	side *= -1
	
	for h in get_tree().get_nodes_in_group("heart"):
		h.queue_free()
		
	if rng.randi_range(1, 2) < 3:
		var heart = heart_obj.instantiate()
		
		heart_parent.global_position.x = rng.randf_range(-1.75, 1.75)
		heart_parent.global_position.z = rng.randf_range(-0.1, 2)
		heart_parent.global_position.y = 0.144
		
		print(heart_parent.global_position)
		
		heart_parent.add_child(evidence)
