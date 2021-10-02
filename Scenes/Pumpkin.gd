extends Area2D

signal pumpkin_smashed

var sfx_smash = preload("res://Assets/SFX/sfx-smash.wav")

func die():
	get_tree().queue_delete(self)

func _on_Pumpkin_body_entered(body):
	if body.is_in_group("Bone"):
		if body.throwing_state:
			emit_signal("pumpkin_smashed")
			$SmashStreamPlayer.stream = sfx_smash
			$SmashStreamPlayer.play()
			set_collision_layer(0)
			set_collision_mask(0)
			visible = false


func _on_SmashStreamPlayer_finished():
	die()
