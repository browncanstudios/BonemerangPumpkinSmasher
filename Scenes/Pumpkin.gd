extends Area2D

signal pumpkin_smashed

func die():
	get_tree().queue_delete(self)

func _on_Pumpkin_body_entered(body):
	if body.is_in_group("Bone"):
		emit_signal("pumpkin_smashed")
		die()
