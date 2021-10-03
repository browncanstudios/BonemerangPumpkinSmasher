extends Node2D

# I am doing some silly hardcoding path behavior for now
# as a quick hack to get this feature in by the game jam deadline
class MyPath:
	var point_a: Vector2
	var point_b: Vector2

	func _init(a, b):
		point_a = a
		point_b = b

var paths = [
	MyPath.new(Vector2(160, -120), Vector2(160, 112)),
	MyPath.new(Vector2(64, -120), Vector2(64, 112)),
	MyPath.new(Vector2(256, -120), Vector2(256, 112)),
]

var rng = RandomNumberGenerator.new()
var entering = true
var path: MyPath

func die():
	get_tree().queue_delete(self)

func _ready():
	rng.randomize()

	# randomly select left- or right-facing
	if rng.randf() > 0.5:
		set_scale(Vector2(-1, 1))

	# pick a random path
	var x = rng.randf()
	if x < 0.33:
		path = paths[0]
	elif x < 0.66:
		path = paths[1]
	else:
		path = paths[2]

	global_position = path.point_a

func _physics_process(delta):
	# either move towards point b, or point a
	if entering:
		position += delta * 40 * (path.point_b - path.point_a).normalized()
		if global_position.distance_to(path.point_b) < 8:
			entering = false
	else:
		position += delta * 40 * (path.point_a - path.point_b).normalized()
		if global_position.distance_to(path.point_a) < 8:
			die()
