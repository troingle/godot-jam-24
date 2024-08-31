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

@onready var hurt_timer = $HurtTimer

@onready var hurt_sound = $Hurt
@onready var collect_sound = $Collect
@onready var bump_sound = $Bump

@onready var proceed_timer = $ProceedTimer

const SPEED = 2.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var side = 1
var rng = RandomNumberGenerator.new()

var hp = 3
var can_hurt = true

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
	
	handle_hp()
	
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
	
	if not game.cutscene_running:
		move_and_slide()
	
	if hp <= 0 or Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
func collect():
	if game.score == 0:
		game.gavel_wait.start()
		$"../GavelStuff/GavelMove".play("move_in")
		$"../GavelStuff".visible = true
	
	game.score += 1
	$Collect.play()
	
	var evidence = evidence_obj.instantiate()
	parent.global_position.x = rng.randf_range(0.3, 1.75) * side
	parent.global_position.z = rng.randf_range(-0.26, 2)
	parent.add_child(evidence)
	side *= -1
	
	for h in get_tree().get_nodes_in_group("heart"):
		h.queue_free()
		
	if rng.randi_range(1, 5) == 1 and hp != 5:
		var heart = heart_obj.instantiate()	
		
		heart_parent.global_position.x = rng.randf_range(-1.75, 1.75)
		heart_parent.global_position.z = rng.randf_range(-0.1, 2)
		heart_parent.global_position.y = 0.144
		
		heart_parent.add_child(heart)
		
func hurt():
	if can_hurt:
		hp -= 1
		$Hurt.play()
		can_hurt = false
		hurt_timer.start()

func _on_hurt_timer_timeout() -> void:
	can_hurt = true
	
func handle_hp():
	if hp == 5:
		$"../CanvasLayer/Hidden/Heart".visible = true
		$"../CanvasLayer/Hidden/Heart2".visible = true
		$"../CanvasLayer/Hidden/Heart3".visible = true
		$"../CanvasLayer/Hidden/Heart4".visible = true
		$"../CanvasLayer/Hidden/Heart5".visible = true
	elif hp == 4:
		$"../CanvasLayer/Hidden/Heart".visible = true
		$"../CanvasLayer/Hidden/Heart2".visible = true
		$"../CanvasLayer/Hidden/Heart3".visible = true
		$"../CanvasLayer/Hidden/Heart4".visible = true
		$"../CanvasLayer/Hidden/Heart5".visible = false
	elif hp == 3:
		$"../CanvasLayer/Hidden/Heart".visible = true
		$"../CanvasLayer/Hidden/Heart2".visible = true
		$"../CanvasLayer/Hidden/Heart3".visible = true
		$"../CanvasLayer/Hidden/Heart4".visible = false
		$"../CanvasLayer/Hidden/Heart5".visible = false
	elif hp == 2:
		$"../CanvasLayer/Hidden/Heart".visible = true
		$"../CanvasLayer/Hidden/Heart2".visible = true
		$"../CanvasLayer/Hidden/Heart3".visible = false
		$"../CanvasLayer/Hidden/Heart4".visible = false
		$"../CanvasLayer/Hidden/Heart5".visible = false
	elif hp == 1:
		$"../CanvasLayer/Hidden/Heart".visible = true
		$"../CanvasLayer/Hidden/Heart2".visible = false
		$"../CanvasLayer/Hidden/Heart3".visible = false
		$"../CanvasLayer/Hidden/Heart4".visible = false
		$"../CanvasLayer/Hidden/Heart5".visible = false
	elif hp == 0:
		$"../CanvasLayer/Hidden/Heart".visible = false
		$"../CanvasLayer/Hidden/Heart2".visible = false
		$"../CanvasLayer/Hidden/Heart3".visible = false
		$"../CanvasLayer/Hidden/Heart4".visible = false
		$"../CanvasLayer/Hidden/Heart5".visible = false


func _on_proceed_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/end.tscn")
