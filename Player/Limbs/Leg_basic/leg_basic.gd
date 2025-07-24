extends Node2D

@onready var KneeMuscle = $KneeMuscle
@onready var AnkleMuscle = $AnkleMuscle
@onready var Thigh = $Thigh

var tilt_force := 1.0
var max_tilt_speed := 100.0

var knee_stiffness: float
var ankle_stiffness: float
var knee_rest_length: float
var ankle_rest_length: float

func _ready() -> void:
	knee_stiffness = KneeMuscle.stiffness
	ankle_stiffness = AnkleMuscle.stiffness
	knee_rest_length = KneeMuscle.rest_length
	ankle_rest_length = AnkleMuscle.rest_length

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("w"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length

	elif Input.is_action_just_released("w"):
		KneeMuscle.stiffness = knee_stiffness
		AnkleMuscle.stiffness = ankle_stiffness

	elif Input.is_action_pressed("s"):
		KneeMuscle.rest_length = 5
		AnkleMuscle.rest_length = 5
		await get_tree().create_timer(1).timeout
		KneeMuscle.rest_length = knee_rest_length
		AnkleMuscle.rest_length = ankle_rest_length
	
	# Tilt control with velocity clamping
	var velocity = Thigh.linear_velocity

	if Input.is_action_pressed("a"):
		velocity.x = max(velocity.x - tilt_force, -max_tilt_speed)
	elif Input.is_action_pressed("d"):
		velocity.x = min(velocity.x + tilt_force, max_tilt_speed)

	Thigh.linear_velocity = velocity
