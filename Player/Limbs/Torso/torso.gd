extends Limb

@export var torque_force: float = 50.0

func physics_update(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		get_parent().apply_torque_impulse(-torque_force)
	elif Input.is_action_pressed("move_right"):
		get_parent().apply_torque_impulse(torque_force)
