extends Node2D
 
func _ready() -> void:
	#attaches joints to the main body
	var joint =get_node("Left Arm Link").get_node("Arm Attach")
	joint.set_node_a(get_node("Left Arm Link").get_path())
	joint.set_node_b(get_node("Left Arm Link").get_node("Arm_Enemy").get_child(0).get_path())
