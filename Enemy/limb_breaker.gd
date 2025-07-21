extends RigidBody2D
@export var tension_threshold: int 
func _physics_process(delta: float) -> void:
	var tension:Vector2 = linear_velocity - get_parent().get_node("Arm_Enemy").get_child(0).linear_velocity
	if tension.length() > 1000:
		queue_free()
