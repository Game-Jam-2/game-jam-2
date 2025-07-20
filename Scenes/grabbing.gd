extends State
var speed : int = 1000
var swing_pin: PinJoint2D
var sprite:Sprite2D
var texture : Texture = load("res://icon.svg")
var pull:bool = true
func enter(previous_state_path : String,data :={}) -> void:
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(object_reference.get_path())
	swing_pin.set_node_b(data["object_collided"].get_path())
	swing_pin.bias = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	object_reference.get_parent().add_child(swing_pin)
	print("Pin Position" + str(swing_pin.global_position))
	
		
func _physics_process(delta: float) -> void:
	var mouse_position = object_reference.get_global_mouse_position()
	var direction:Vector2 = (mouse_position - object_reference.get_parent().get_node("Bicep").global_position).normalized()
	var distance = (mouse_position -object_reference.get_parent().get_node("Bicep").global_position).length()
	var force = direction * distance * speed * delta
	object_reference.get_parent().get_node("Bicep").apply_central_force(force)
	if pull:
		object_reference.get_parent().get_node("Bicep").apply_central_force(force * 100)
		object_reference.get_parent().get_node("ForeArm").apply_central_force(force * 100)
		pull = false
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("Grab"):
		swing_pin.queue_free()
		finished.emit("Moving")
	if event.is_action_pressed("Pull"):
		pull = true
		
		
