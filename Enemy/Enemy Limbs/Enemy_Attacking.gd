extends State
var raycasts : Array[RayCast2D]
func enter(previous_state_path: String,data := {}):
	object_reference.get_parent().get_parent().get_node("Torso").get_node("Attack_Range").area_exited.connect(attack_range_exited)
	raycasts = data["raycasts"]

func attack_range_exited(area:Area2D):
	var data = {"raycasts": raycasts}	
	finished.emit("Attacking",data)
