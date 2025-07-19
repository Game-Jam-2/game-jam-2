extends State
var speed : int = 500
var swing_pin: PinJoint2D
func enter(previous_state_path : String,data :={}) -> void:
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(object_reference.get_path())
	swing_pin.set_node_b(data["object_collided"].get_path())
	swing_pin.global_position = object_reference.global_position
	object_reference.get_parent().add_child(swing_pin)
	print("break")
	
		
func _physics_process(delta: float) -> void:
	var mouse_position = object_reference.get_global_mouse_position()
	var direction:Vector2 = (mouse_position - object_reference.global_position).normalized()
	var distance = (mouse_position -object_reference.global_position).length()
	var force = direction * distance * speed * delta
	object_reference.apply_central_force(force)

	
