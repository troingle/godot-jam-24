extends Node3D

@onready var player = $"../Player"

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

var phase = 1
var score = 0

var gavel_num = 1
var old_gavel_num = 1
var original_gavel_time = 999

var rng = RandomNumberGenerator.new()

func _ready():
	original_gavel_time = gavel_wait.wait_time

func _process(delta):
	if phase == 1:
		gavel_wait.wait_time = original_gavel_time - score * 0.052
		$"../CanvasLayer/EvidenceLabel".text = str(score) + "/20"
		if score >= 20:
			phase += 1
			gavel_move.play("move_out")
			
	elif phase == 2:
		$"../CanvasLayer/EvidenceLabel".text = str(score) + "/40"
		
	if $"../GavelStuff".global_position.x >= 2.1:
		$"../GavelStuff".visible = false

func _on_gavel_wait_timeout():
	if phase == 1:
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
	elif player.global_position.z > 0.459 and player.global_position.z < 1.332 and old_gavel_num == 1:
		player.hp -= 1
	elif player.global_position.z > 1.33 and old_gavel_num == 2:
		player.hp -= 1
