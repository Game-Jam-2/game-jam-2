extends Node2D

@onready var KneeMuscle = $KneeMuscle
@onready var AnkleMuscle = $AnkleMuscle
@onready var Thigh = $Thigh

var tilt_force := 1.0
var max_tilt_speed := 100.0

func _process(delta: float) -> void:
	
	# Leg extension
	if Input.is_action_pressed("w"):
		KneeMuscle.stiffness = 500
		AnkleMuscle.stiffness = 500
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length

	if Input.is_action_just_released("w"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64

	# Leg contraction
	if Input.is_action_pressed("s"):
		KneeMuscle.rest_length = 5
		AnkleMuscle.rest_length = 5

	# Tilt control with velocity clamping
	var velocity = Thigh.linear_velocity

	if Input.is_action_pressed("a"):
		velocity.x = max(velocity.x - tilt_force, -max_tilt_speed)
	elif Input.is_action_pressed("d"):
		velocity.x = min(velocity.x + tilt_force, max_tilt_speed)

	Thigh.linear_velocity = velocity
