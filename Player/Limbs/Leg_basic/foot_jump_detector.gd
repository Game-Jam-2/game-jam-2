extends RigidBody2D

signal grounded_state_changed(is_grounded)
@onready var ground_check: Area2D = get_node("ground_detection")

var is_grounded = false

var air_mass = 2.0
var grounded_mass = 3.0
var air_grav = 1.0
var grounded_grav = 2.0

func _ready():
	ground_check.connect("body_entered", _on_ground_entered)
	ground_check.connect("body_exited", _on_ground_exited)

func _on_ground_entered(body):
	if body.is_in_group("Ground"):
		is_grounded = true
		gravity_scale = grounded_grav
		mass = grounded_mass
		emit_signal("grounded_state_changed", true)

func _on_ground_exited(body):
	if body.is_in_group("Ground"):
		is_grounded = false
		gravity_scale = air_grav
		mass = air_mass
		emit_signal("grounded_state_changed", false)
