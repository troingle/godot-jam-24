extends Node3D

@onready var player = $"../Player"

@onready var saw = $"../Sawblade"
@onready var big_saw = $"../BigSaw"

@onready var gavel_wait = $GavelWait
@onready var warning_show_timer = $WarningShowTimer
@onready var attack_timer = $AttackTimer
@onready var gavel_anim = $"../GavelStuff/GavelSmash"
@onready var flash_anim = $"../Flashes/FlashAnim"
@onready var gavel_move = $"../GavelStuff/GavelMove"

@onready var gavels = [$"../GavelStuff/Gavel", $"../GavelStuff/Gavel2", $"../GavelStuff/Gavel3"]
@onready var gavel_warnings = [$"../GavelStuff/Warning1", $"../GavelStuff/Warning2", $"../GavelStuff/Warning3"]
var anim_names = ["smash1", "smash2", "smash3"]
var flash_anim_names = ["flash1", "flash2", "flash3"]

@onready var target_obj = load("res://scenes/target.tscn")
@onready var targets = $"../Targets"

@onready var adding_timer = $AddingTimer

@onready var bar = $"../Judge/Bar"

@onready var fade_anim = $"../CanvasLayer/White/Anim"

var phase = 1
var score = 0

var gavel_num = 1
var old_gavel_num = 1
var original_gavel_time = 999

var brought_in = false

var last_pos = Vector3(9999, 0, 0)

var rng = RandomNumberGenerator.new()

@onready var dialogue_text = $"../Judge/Dialogue"
var cutscene_running = true

var dialogue = ["So you really want to prove 
your innocence?", "I don't usually do this, and
you have already been proven guilty...", "But I will do anything
to restore order in my courtroom.", "It's your choice.", ""]
var dialogue_num = 0

func _ready():
	original_gavel_time = gavel_wait.wait_time
	Music.stop()

func _process(delta):
	$"../CanvasLayer/Hidden/EvidenceLabel".text = str(score)
	if phase == 1:
		gavel_wait.wait_time = original_gavel_time - score * 0.0
		if score >= 20 and score < 45:
			phase += 0.5
			adding_timer.start()
			gavel_move.play("move_out")
			
	if phase == 2:
		handle_saws(delta, true)
		
		if score >= 45:
			phase += 0.5
			adding_timer.start()
			big_saw.global_position = Vector3(-5.631, 0.039, 0.89)
			saw.global_position = Vector3(-5.631, 0.039, 0.89)

	if phase == 3:
		if score >= 58:
			$"../GavelStuff".visible = true
			if not brought_in:
				brought_in = true
				gavel_wait.start()
				gavel_move.play("move_in")
				gavel_wait.wait_time = 1.5
		if score >= 79:
			handle_saws(delta, false)
		if score >= 87:
			phase += 1
			big_saw.global_position = Vector3(-5.631, 0.039, 0.89)
			saw.global_position = Vector3(-5.631, 0.039, 0.89)
			$"../GavelStuff".visible = false
			$"../Judge/AnimationPlayer".play("fall")
			bar.visible = false
			fade_anim.play("flash")
			if Music.is_playing():
				print("Stop")
				Music.stop()
				$Explode.play()
			player.proceed_timer.start()
		

	if dialogue_text.visible and Input.is_action_just_pressed("space"):
		player.bump_sound.play()
		dialogue_num += 1
		if dialogue_num == 4:
			dialogue_text.visible = false
			$"../Camera3D/CameraMove".play("move")
			$"../CanvasLayer/ProceedTip".visible = false
			$"../Intro".stop()
			cutscene_running = false
		
	dialogue_text.text = dialogue[dialogue_num]
	
	if $"../GavelStuff".global_position.x >= 2.08 and score <= 50:
		$"../GavelStuff".visible = false
		
	if score != 0 and score < 86:
		$"../Info".visible = false
		$"../Judge/Bar".visible = true
		$"../CanvasLayer/Hidden".visible = true
		if !Music.is_playing():
			Music.play()

		
	bar.scale.x = (87 - score) * 1.7
	

func _on_gavel_wait_timeout():
	if phase == 1 or (phase == 3 and score >= 58):
		gavel_anim.play(anim_names[gavel_num])
		
		old_gavel_num = gavel_num
		gavel_num = rng.randi_range(0, 2)
		
		warning_show_timer.start()
		attack_timer.start()

func _on_warning_show_timer_timeout():
		for w in gavel_warnings:
			if w == gavel_warnings[gavel_num]:
				w.visible = true
			else:
				w.visible = false

func _on_attack_timer_timeout():
	flash_anim.play(flash_anim_names[old_gavel_num])
	
	if player.global_position.z < 0.459 and old_gavel_num == 0:
		player.hp -= 1
		player.hurt_sound.play()
	elif player.global_position.z > 0.459 and player.global_position.z < 1.332 and old_gavel_num == 1:
		player.hp -= 1
		player.hurt_sound.play()
	elif player.global_position.z > 1.33 and old_gavel_num == 2:
		player.hp -= 1
		player.hurt_sound.play()
	
	player.bump_sound.play()
		
func handle_saws(delta, include_big):
	if saw.global_position.x < player.global_position.x:
		saw.global_position.x += saw.speed * delta
	else:
		saw.global_position.x -= saw.speed * delta
	if saw.global_position.z < player.global_position.z:
		saw.global_position.z += saw.speed * delta
	else:
		saw.global_position.z -= saw.speed * delta
	
	if score >= 32 and include_big:
		if big_saw.global_position.x < player.global_position.x:
			big_saw.global_position.x += big_saw.speed * delta
		else:
			big_saw.global_position.x -= big_saw.speed * delta
		if big_saw.global_position.z < player.global_position.z:
			big_saw.global_position.z += big_saw.speed * delta
		else:
			big_saw.global_position.z -= big_saw.speed * delta
			
			
func _on_spawn_target_timeout() -> void:
	if phase == 3:
		var target = target_obj.instantiate()
		
		target.position = last_pos #Vector3(player.position.x, 0.144, player.position.z)

		targets.add_child(target)
		
		last_pos = player.global_position

func _on_adding_timer_timeout() -> void:
	phase += 0.5
