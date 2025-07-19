extends RigidBody2D
@export var speed = 500
func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction:Vector2 = (mouse_position - global_position).normalized()
	var distance = (mouse_position - global_position).length()
	var force = direction * distance * speed * delta
	apply_central_force(force)
