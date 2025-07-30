extends State
var path_to_enemy_root_node : Node2D
var raycasts: Array[RayCast2D]
var latest_player_position: Vector2
var hand : RigidBody2D
func enter(previous_state_path: String , data := {}):
	hand = object_reference.get_parent().get_node("Hand")
	path_to_enemy_root_node = hand.get_parent().get_parent().get_parent().get_node("Torso")
	assert(hand.get_parent().get_parent().get_parent().name == "Enemy")#check of paths
	for child in path_to_enemy_root_node.get_children():
		if child is RayCast2D:
			raycasts.append(child)


func physics_update(_delta:float):
	for raycast in raycasts:
		if raycast.is_colliding() and raycast.get_collider().name == "Torso" :
			latest_player_position = raycast.get_collision_point()
			var data:Dictionary = {"player_position":latest_player_position,"raycasts":raycasts}
			finished.emit("Enemy_Arm_Chasing",data)
			
