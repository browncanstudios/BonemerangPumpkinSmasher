extends Node2D

var rng = RandomNumberGenerator.new()

var pumpkins_smashed = 0

var initial_game_time = 60
var time_remaining = initial_game_time

func _ready():
	rng.randomize()
	$CanvasLayer/TimerLabel.set_text("%02d" % time_remaining)
	$CanvasLayer/GameOverContainer.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_select"):
		if time_remaining == 0:
			pumpkins_smashed = 0
			$Player.bones = 3
			for node in get_children():
				if node.is_in_group("Bone"):
					node.die()
			$CanvasLayer/HUD/HBoxContainer/SmashedPumpkinsCounterContainer/Label.set_text("x" + str(pumpkins_smashed))
			$CanvasLayer/HUD/HBoxContainer/BoneCounterContainer/Label.set_text("x" + str($Player.bones))
			time_remaining = initial_game_time
			$GameTimer.start()
			$GhostPumpkinSpawnTimer.start()
			$CanvasLayer/TimerLabel.set_text("%02d" % time_remaining)
			$CanvasLayer/GameOverContainer.visible = false
		elif $Player.bones > 0:
			var bone_instance = load("res://Scenes/Bone.tscn").instance()
			add_child(bone_instance)
			bone_instance.init($Player.global_position + Vector2(0, -15))
			$Player.bones -= 1
			$CanvasLayer/HUD/HBoxContainer/BoneCounterContainer/Label.set_text("x" + str($Player.bones))

func _on_Pumpkin_pumpkin_smashed():
	pumpkins_smashed += 1
	$CanvasLayer/HUD/HBoxContainer/SmashedPumpkinsCounterContainer/Label.set_text("x" + str(pumpkins_smashed))

func _on_Player_collected_bone():
	$CanvasLayer/HUD/HBoxContainer/BoneCounterContainer/Label.set_text("x" + str($Player.bones))

func _on_GhostPumpkinSpawnTimer_timeout():
	var spawn_area = $GhostPumpkinSpawnAreaLeft
	var velocity = Vector2(rng.randi_range(80, 120), 0)
	if rng.randf() > 0.5:
		spawn_area = $GhostPumpkinSpawnAreaRight
		velocity = Vector2(rng.randi_range(-80, -120), 0)

	var min_x = spawn_area.global_position.x - spawn_area.get_node("Shape").get_shape().get_extents().x / 2
	var max_x = spawn_area.global_position.x + spawn_area.get_node("Shape").get_shape().get_extents().x / 2
	var min_y = spawn_area.global_position.y - spawn_area.get_node("Shape").get_shape().get_extents().y / 2
	var max_y = spawn_area.global_position.y + spawn_area.get_node("Shape").get_shape().get_extents().y / 2

	var spawn_position = Vector2(rng.randi_range(min_x, max_x), rng.randi_range(min_y, max_y))

	var ghost_pumpkin_instance = load("res://Scenes/GhostPumpkin.tscn").instance()
	add_child(ghost_pumpkin_instance)
	ghost_pumpkin_instance.global_position = spawn_position
	ghost_pumpkin_instance.velocity = velocity
	ghost_pumpkin_instance.get_node("Pumpkin").connect("pumpkin_smashed", self, "_on_Pumpkin_pumpkin_smashed")

func _on_GameTimer_timeout():
	time_remaining -= 1
	$CanvasLayer/TimerLabel.set_text("%02d" % time_remaining)
	if time_remaining == 0:
		$GameTimer.stop()
		$GhostPumpkinSpawnTimer.stop()
		$CanvasLayer/GameOverContainer.visible = true
