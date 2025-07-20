extends Node2D
 
func _ready() -> void:
	var joint = get_node("Arm Attach")
	joint.set_node_a(get_node("Left Arm Link"))
	joint.set_node_b(get_node("Arm").get_child(0))
