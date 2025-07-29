extends State

signal grabbing
signal releasing

var speed : int = 600
var swing_pin: PinJoint2D
var sprite:Sprite2D
var texture:Texture = load("res://icon.svg")
var pull:bool = true
var pull_strength:int = 100
var hand_boost:int = 500
var hand:RigidBody2D
var bicep:RigidBody2D
var forearm:RigidBody2D
func enter(previous_state_path : String,data :={}) -> void:
	hand = object_reference.get_parent().get_node("Hand")
	bicep = object_reference.get_parent().get_node("Bicep")
	forearm = object_reference.get_parent().get_node("ForeArm")
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(object_reference.get_path())
	swing_pin.set_node_b(data["object_collided"].get_path())
	swing_pin.bias = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	object_reference.get_parent().add_child(swing_pin)
	grabbing.emit()
	
func physics_update(delta: float) -> void:
	var mouse_position = hand.get_global_mouse_position()
	var direction:Vector2 = (mouse_position - hand.global_position).normalized()
	var distance = (mouse_position -hand.global_position).length()
	var force = direction * speed * delta
	
		

	hand.apply_central_force(force *  hand_boost)
	if pull:
		bicep.apply_impulse(force * pull_strength)
		forearm.apply_impulse(force * pull_strength)
		pull = false
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse"):
		swing_pin.queue_free()
		releasing.emit()
		finished.emit("Moving")
	if event.is_action_pressed("space"):
		pull = true
		
		
