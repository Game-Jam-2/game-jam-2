extends RigidBody2D
@onready var GrappleRay = $Head/GrappleRay
@onready var Tongue = $Head/Tongue
@onready var Anchor = $Anchor
@onready var GrappleJoint = $GrappleJoint

var grappling = false

func _process(delta: float) -> void:
	if not grappling and Input.is_action_just_pressed("left_mouse"):
		pass
		#grapple
