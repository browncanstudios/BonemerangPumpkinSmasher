extends KinematicBody2D

signal collected_bone

export var speed = 100

var velocity
var bones

func soft_reset():
	velocity = Vector2(speed, 0)
	bones = 3

func _ready():
	soft_reset()

func _physics_process(_delta):
	# vertical movement (using analog joystick or buttons)
	var left_vertical_analog_value = Input.get_joy_axis(0, JOY_AXIS_1)
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	elif Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		velocity.y = speed
	elif abs(left_vertical_analog_value) > 0.1:
		velocity.y = left_vertical_analog_value * speed
	else:
		velocity.y = 0

	# horizontal movement (using analog joystick or buttons)
	var left_horizontal_analog_value = Input.get_joy_axis(0, JOY_AXIS_0)
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		velocity.x = - speed
	elif Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif abs(left_horizontal_analog_value) > 0.1:
		velocity.x = left_horizontal_analog_value * speed
	else:
		velocity.x = 0

	var _returned_velocity = move_and_slide(velocity, Vector2(0, 0), false, 4, 0, false)

	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("Bone"):
			# this "will_die" is necessary because die() doesn't happen right away
			# but the same Bone might have had multiple "collisions" with Player this frame
			if !collision.collider.will_die:
				collision.collider.die()
				bones += 1
				emit_signal("collected_bone")
