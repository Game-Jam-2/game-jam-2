extends RigidBody2D

var move_speed = 8000
var deadzone = 20.0



func _physics_process(delta: float) -> void:
	var target_pos = get_global_mouse_position()
	var to_target = target_pos - global_position
	var distance = to_target.length()

	if freeze != true:5
		if distance > deadzone:
			var direction = to_target.normalized()
			apply_central_force(direction * move_speed)
		else:
			linear_velocity = linear_velocity * 0.8
