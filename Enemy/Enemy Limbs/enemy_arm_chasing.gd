extends State

var player_position:Vector2
var raycasts:Array[RayCast2D]
var speed:int = 1000
var floor_pos:Vector2
func enter(previous_state_path: String,data:={}):
	player_position = data["player_position"]
	raycasts = data["raycasts"]
	
func physics_update(_delta:float):
	for raycast in raycasts:
		if raycast.is_colliding() and raycast.get_collider().name == "Torso":
			player_position = raycast.get_collision_point()
		if raycast.is_colliding() and raycast.get_collider().is_in_group("Ground"):
			floor_pos = raycast.get_collision_point()

	var direction:Vector2 = (player_position - object_reference.global_position)
	var force = direction.x * speed * _delta
	object_reference.apply_central_force(Vector2(force,floor_pos.y))
