extends Node2D

@onready var KneeMuscle = $KneeMuscle
@onready var AnkleMuscle = $AnkleMuscle

func _process(delta: float) -> void:
	if Input.is_action_pressed("w"):
		KneeMuscle.stiffness = 500
		AnkleMuscle.stiffness = 500
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length
	if Input.is_action_just_released("w"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64
	if Input.is_action_pressed("s"):
		KneeMuscle.rest_length = 5
		AnkleMuscle.rest_length = 5
	if Input.is_action_pressed("a"):
		#tilt body left
		pass
	if Input.is_action_pressed("d"):
		#tilt body right
		pass
