extends RigidBody2D
@export var tension_threshold: int
var limb_reference: Node2D 
func _physics_process(delta: float) -> void:
	if get_child_count() == 2:
		limb_reference = get_child(1)
		print(limb_reference)

		var tension:Vector2 = linear_velocity - get_child(1).get_child(0).linear_velocity
		if tension.length() > tension_threshold:
			remove_child(limb_reference)
			get_tree().root.add_child(limb_reference)
			limb_reference.global_position = global_position
			var idle_state_name = limb_reference.name + "_" + "Idle"
			limb_reference.get_child(1)._transistion_to_next_state(idle_state_name,{})			

 
