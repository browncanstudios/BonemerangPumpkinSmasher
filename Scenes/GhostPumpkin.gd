extends Node2D

export var velocity = Vector2(100, 0)

func _physics_process(delta):
	if velocity.x > 0:
		set_scale(Vector2(1, 1))
	elif velocity.x < 0:
		set_scale(Vector2(-1, 1))

	position += velocity * delta
