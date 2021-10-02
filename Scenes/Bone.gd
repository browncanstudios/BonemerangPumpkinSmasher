# TODO: think about cleaning up/simplifying

extends RigidBody2D

var sfx_hit = preload("res://Assets/SFX/sfx-hit.wav")
var sfx_collected = preload("res://Assets/SFX/sfx-hit.wav")

var rng = RandomNumberGenerator.new()
var control_magnitude = 5
var return_magnitude = 0.1
var throw_magnitude = 300
var return_position = Vector2(160, 120)
var throwing_state = false
var returning_state = false
var has_entered_upper_area = false
var was_collected = false

func dampen():
	throwing_state = false
	set_linear_damp(10)
	set_angular_damp(10)
	$ReturnTimer.start()

func was_collected():
	was_collected = true
	play_sfx_collected()
	set_collision_layer(0)
	set_collision_mask(0)
	visible = false

func die():
	get_tree().queue_delete(self)

func init(glo_pos):
	global_position = glo_pos
	return_position = global_position
	apply_central_impulse(throw_magnitude * Vector2(0, -1))
	set_angular_velocity(10.0 * rng.randf_range(-PI, PI))
	throwing_state = true

func _ready():
	rng.randomize()

func _physics_process(delta):
	if throwing_state:
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
	elif returning_state:
		global_position += 100 * delta * (Vector2(160, 192) - global_position).normalized()
		if global_position.distance_to(Vector2(160, 192)) < 5:
			returning_state = false
			set_collision_layer_bit(2, true)
			set_collision_mask_bit(2, true)
			set_collision_layer_bit(3, true)
			set_collision_mask_bit(3, true)

func _on_Bone_body_entered(body):
	if body.is_in_group("Tombstone"):
		play_sfx_hit()
		dampen()
	if body.is_in_group("Bone"):
		play_sfx_hit()

func _on_ReturnTimer_timeout():
	returning_state = true
	set_collision_layer_bit(2, false)
	set_collision_mask_bit(2, false)
	set_collision_layer_bit(3, false)
	set_collision_mask_bit(3, false)
	$BlinkTimer.start()

func _on_BlinkTimer_timeout():
	# quick hack to prevent a collected bone from flashing
	if was_collected:
		return

	if returning_state:
		visible = (visible == false)
	else:
		visible = true
		$BlinkTimer.stop()

func play_sfx_hit():
		$HitStreamPlayer.stream = sfx_hit
		$HitStreamPlayer.play()

func play_sfx_collected():
		$CollectedStreamPlayer.stream = sfx_collected
		$CollectedStreamPlayer.play()

func _on_CollectedStreamPlayer_finished():
	die()
