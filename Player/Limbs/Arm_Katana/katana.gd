extends RigidBody2D

var move_speed = 8000



func _physics_process(delta: float) -> void:
	var direction = (get_global_mouse_position() - global_position).normalized()
	apply_central_force(direction * move_speed)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right_mouse"):
		lock_rotation = true
	elif Input.is_action_just_released("right_mouse"):
		lock_rotation = false
