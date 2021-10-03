extends Node2D

export var velocity = Vector2(100, 0)

func die():
	get_tree().queue_delete(self)

func _physics_process(delta):
	if velocity.x > 0:
		set_scale(Vector2(1, 1))
	elif velocity.x < 0:
		set_scale(Vector2(-1, 1))

	position += velocity * delta

func _on_DieTimer_timeout():
	die()
