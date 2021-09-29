extends Node2D

var rng = RandomNumberGenerator.new()

var pumpkins_smashed
var initial_game_time
var time_remaining
var started = false

func soft_reset():
	$Player.soft_reset()

	pumpkins_smashed = 0
	initial_game_time = 60
	time_remaining = initial_game_time

	for node in get_children():
		if node.is_in_group("Bone"):
			node.die()

	$CanvasLayer/HUD/HBoxContainer/SmashedPumpkinsCounterContainer/Label.set_text("x" + "%02d" % pumpkins_smashed)
	$CanvasLayer/HUD/HBoxContainer/BoneCounterContainer/Label.set_text("x" + str($Player.bones))
	$CanvasLayer/TimerLabel.set_text("%02d" % time_remaining)
	$CanvasLayer/GameOverContainer.visible = false
	$CanvasLayer/StartContainer.visible = false

	$GameTimer.start()
	$GhostPumpkinSpawnTimer.start()

func _ready():
	rng.randomize()
	$CanvasLayer/StartContainer.visible = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_select"):
		if !started:
			started = true
			soft_reset()
			return

		if time_remaining == 0:
			# game over, this will reset/restart/retry
			soft_reset()
		elif $Player.bones > 0:
			# shoot a bone
			var bone_instance = load("res://Scenes/Bone.tscn").instance()
			add_child(bone_instance)
			bone_instance.init($Player.global_position + Vector2(0, -15))

			# decrement the number of bones the player has and update our bone label
			$Player.bones -= 1
			$CanvasLayer/HUD/HBoxContainer/BoneCounterContainer/Label.set_text("x" + str($Player.bones))

func _on_Pumpkin_pumpkin_smashed():
	pumpkins_smashed += 1
	$CanvasLayer/HUD/HBoxContainer/SmashedPumpkinsCounterContainer/Label.set_text("x" + "%02d" % pumpkins_smashed)

func _on_Player_collected_bone():
	# the number of bones the player has was incremented,
	# here we just need to update our bone label
	$CanvasLayer/HUD/HBoxContainer/BoneCounterContainer/Label.set_text("x" + str($Player.bones))

func _on_GhostPumpkinSpawnTimer_timeout():
	# determine the position and velocity of the ghost-pumpkin we are about to spawn
	var spawn_area = $GhostPumpkinSpawnAreaLeft
	var velocity = Vector2(rng.randi_range(80, 120), 0)
	if rng.randf() > 0.5:
		spawn_area = $GhostPumpkinSpawnAreaRight
		velocity = Vector2(rng.randi_range(-80, -120), 0)
	var spawn_point = spawn_area.spawn_point()

	# spawn our ghost-pumpkin object
	var ghost_pumpkin_instance = load("res://Scenes/GhostPumpkin.tscn").instance()
	add_child(ghost_pumpkin_instance)
	ghost_pumpkin_instance.global_position = spawn_point
	ghost_pumpkin_instance.velocity = velocity
	ghost_pumpkin_instance.get_node("Pumpkin").connect("pumpkin_smashed", self, "_on_Pumpkin_pumpkin_smashed")

func _on_GameTimer_timeout():
	time_remaining -= 1
	$CanvasLayer/TimerLabel.set_text("%02d" % time_remaining)

	# game over!
	if time_remaining == 0:
		$GameTimer.stop()
		$GhostPumpkinSpawnTimer.stop()
		$CanvasLayer/GameOverContainer.visible = true

func _on_UpperArea_body_entered(body):
	if body.is_in_group("Bone"):
		body.has_entered_upper_area = true

func _on_LowerArea_body_entered(body):
	if body.is_in_group("Bone"):
		if body.has_entered_upper_area:
			body.dampen()
