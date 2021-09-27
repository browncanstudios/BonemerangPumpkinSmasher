extends Area2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func spawn_point():
	var min_x = global_position.x - $CollisionShape2D.get_shape().get_extents().x / 2
	var max_x = global_position.x + $CollisionShape2D.get_shape().get_extents().x / 2
	var min_y = global_position.y - $CollisionShape2D.get_shape().get_extents().y / 2
	var max_y = global_position.y + $CollisionShape2D.get_shape().get_extents().y / 2

	var point = Vector2(rng.randi_range(min_x, max_x), rng.randi_range(min_y, max_y))
	
	return point
