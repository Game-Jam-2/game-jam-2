extends Node2D
class_name Leg

@onready var thigh: RigidBody2D = $Thigh
@onready var calf: RigidBody2D = $Calf
@onready var foot: RigidBody2D = $Foot

var hip_joint: DampedSpringJoint2D
var knee_joint: DampedSpringJoint2D
var ankle_joint: DampedSpringJoint2D

func _ready() -> void:
	var knee_joint = _create_joint(thigh, calf, calf.global_position)
	var ankle_joint = _create_joint(calf, foot, foot.global_position)
	add_child(knee_joint)
	add_child(ankle_joint)

func setup_joint(torso: RigidBody2D, attach_pos: Vector2) -> void:
	var hip_joint = _create_joint(thigh, torso, attach_pos)
	get_parent().add_child(hip_joint)

func _create_joint(a: RigidBody2D, b: RigidBody2D, pos: Vector2) -> PinJoint2D:
	var joint := PinJoint2D.new()
	joint.node_a = a.get_path()
	joint.node_b = b.get_path()
	joint.position = pos
	joint.bias = 0.9
	joint.softness = 0.0
	return joint


func physics_update(delta: float) -> void:
	var tilt_force := 300.0
	var stabilise_force := 200.0
	var crouch_force := 100.0
	var jump_force := 500.0

	# Tilt with A and D
	if Input.is_action_pressed("a"):
		thigh.apply_torque_impulse(-tilt_force * delta)
	elif Input.is_action_pressed("d"):
		thigh.apply_torque_impulse(tilt_force * delta)
	else:
		# Auto-stabilize
		var angle := thigh.rotation
		thigh.apply_torque_impulse(-angle * stabilise_force * delta)
		thigh.apply_torque_impulse(-thigh.angular_velocity * 10 * delta)

	# Crouch with S
	if Input.is_action_pressed("s"):
		thigh.apply_torque_impulse(crouch_force * delta)
		calf.apply_torque_impulse(-crouch_force * delta)

	# Kick / Jump with W
	if Input.is_action_just_pressed("w"):
		foot.apply_impulse(Vector2(0, -jump_force))
