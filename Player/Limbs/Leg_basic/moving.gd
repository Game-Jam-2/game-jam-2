extends State
var hand : RigidBody2D
var speed : int = 500


func physics_update(delta: float) -> void:
	var mouse_position = object_reference.get_global_mouse_position()
	var direction:Vector2 = (mouse_position - object_reference.global_position).normalized()
	var distance = (mouse_position -object_reference.global_position).length()
	var force = direction * distance * speed * delta
	object_reference.apply_central_force(force)

func handle_input(_event:InputEvent) -> void:
	if (_event.is_action_pressed("Grab")):
		print("STATE CHANGE")
		finished.emit("Grabbing")
