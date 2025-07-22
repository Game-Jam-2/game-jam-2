extends RigidBody2D

@onready var Katana = $"../Katana"

var anchor = Vector2.ZERO
var hooked = false

func _process(delta: float) -> void:
	if not hooked:
		if body_entered and (linear_velocity.x > 200 or linear_velocity.y > 200) and Input.is_action_pressed("left_mouse"):
			anchor = global_position
			hooked = true
			Katana.lock_rotation = true
		elif Input.is_action_just_pressed("right_mouse"):
			Katana.lock_rotation = true
		else:
			Katana.lock_rotation = false
	elif Input.is_action_just_released("left_mouse"):
		hooked = false
	else:
		position = anchor
