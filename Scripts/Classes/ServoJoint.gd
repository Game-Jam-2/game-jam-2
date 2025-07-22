# ServoJoint.gd
extends Node2D
class_name ServoJoint  # This registers it as a class

@export var body_a: RigidBody2D
@export var body_b: RigidBody2D

@export var stiffness := 10000.0
@export var damping := 10.0

var target_angle := 0.0

func _physics_process(delta):
	if not (body_a and body_b):
		return
	
	var current_relative_angle = wrapf(body_b.global_rotation - body_a.global_rotation, -PI, PI)
	var error = wrapf(target_angle - current_relative_angle, -PI, PI)
	
	var relative_angular_velocity = body_b.angular_velocity - body_a.angular_velocity
	var torque = stiffness * error - damping * relative_angular_velocity
	print("torque", torque)
	
	body_a.apply_torque(torque)
	body_b.apply_torque(-torque)
	
func set_target_angle(angle_radians):
	target_angle = angle_radians
