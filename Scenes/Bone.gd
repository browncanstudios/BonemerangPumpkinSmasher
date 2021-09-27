# TODO: if alive for too long, start blinking and send back to return position

extends RigidBody2D

var rng = RandomNumberGenerator.new()
var control_magnitude = 5
var return_magnitude = 0.1
var throw_magnitude = 300
var return_position = Vector2(160, 120)
var throwing_state = false
var will_die = false

func die():
	will_die = true
	get_tree().queue_delete(self)

func init(glo_pos):
	global_position = glo_pos
	return_position = global_position
	apply_central_impulse(throw_magnitude * Vector2(0, -1))
	set_angular_velocity(10.0 * rng.randf_range(-PI, PI))
	throwing_state = true

func _ready():
	rng.randomize()

func _physics_process(_delta):
	if !throwing_state:
		return

	apply_central_impulse(return_magnitude * (return_position - global_position))

	# vertical movement (using analog joystick or buttons)
	var right_vertical_analog_value = Input.get_joy_axis(0, JOY_AXIS_3)
	if Input.is_key_pressed(KEY_I) or Input.is_action_pressed("ui_up"):
		apply_central_impulse(control_magnitude * Vector2(0, -1))
	elif Input.is_key_pressed(KEY_K) or Input.is_action_pressed("ui_down"):
		apply_central_impulse(control_magnitude * Vector2(0, 1))
	elif abs(right_vertical_analog_value) > 0.1:
		apply_central_impulse(right_vertical_analog_value * control_magnitude *  Vector2(0, 1))

	# horizontal movement (using analog joystick or buttons)
	var right_horizontal_analog_value = Input.get_joy_axis(0, JOY_AXIS_2)
	if Input.is_key_pressed(KEY_J) or Input.is_action_pressed("ui_left"):
		apply_central_impulse(control_magnitude * Vector2(-1, 0))
	elif Input.is_key_pressed(KEY_L) or Input.is_action_pressed("ui_right"):
		apply_central_impulse(control_magnitude * Vector2(1, 0))
	elif abs(right_horizontal_analog_value) > 0.1:
		apply_central_impulse(right_horizontal_analog_value * control_magnitude * Vector2(1, 0))

	# TODO: refactor this logic
	if global_position.y > return_position.y:
		throwing_state = false
		# if the bone is in the area where we have real tiles
		# (I should really check this with the tilemap I suppose)
		# (or! I define an Area2D where the bones get this dampening)
		if global_position.x > 16 and global_position.x < 320 - 16:
			set_linear_damp(10)
			set_angular_damp(10)
