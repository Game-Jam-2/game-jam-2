extends State

signal grabbing
signal releasing

var speed : int = 1000
var swing_pin: PinJoint2D
var sprite:Sprite2D
var texture:Texture = load("res://icon.svg")
var hand:RigidBody2D
var bicep:RigidBody2D
var forearm:RigidBody2D

func enter(previous_state_path : String,data :={}) -> void:
	hand = object_reference.get_parent().get_node("Hand")
	bicep = object_reference.get_parent().get_node("Bicep")
	forearm = object_reference.get_parent().get_node("ForeArm")


	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(hand.get_path())
	swing_pin.set_node_b(data["object_collided"].get_path())
	swing_pin.bias = 0.9
	swing_pin.softness = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	object_reference.get_parent().add_child(swing_pin)
	grabbing.emit()


func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_released("left_mouse"):
		swing_pin.queue_free()
		releasing.emit()
		finished.emit("Moving")
