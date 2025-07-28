extends State
var raycasts : Array[RayCast2D]
var player_torso:RigidBody2D
var connecter_regex: RegEx = RegEx.new()
var player_limb:RigidBody2D
var first_entry:bool = true
var speed:int = 200

func enter(previous_state_path: String,data := {}):
	print("Attacking State")
	if first_entry:
		object_reference.get_parent().get_parent().get_parent().get_node("Torso").get_node("Attack_Range").body_exited.connect(attack_range_exited)
		raycasts = data["raycasts"]
		player_torso = data["player_torso"]
		connecter_regex.compile("Connector \\d")
		player_limb = get_player_limb().get_child(1).get_child(0)
		first_entry = false

func physics_update(delta: float) -> void:
	var direction:Vector2 = (player_limb.global_position - object_reference.global_position)
	var force:Vector2 = direction * speed * delta
	object_reference.apply_central_force(force)
	
#looking for the limb which is connected to the player if no limbs returns torso
func get_player_limb() -> RigidBody2D:
	var limb_connection_point:RigidBody2D
	var connection_points_names:Array[String]
	for node in player_torso.get_parent().get_children():
		if connecter_regex.search(node.name) != null:
			connection_points_names.append(node.name)
	
	for connection_point in connection_points_names:
		if player_torso.get_parent().get_node(connection_point).get_child_count() > 1:
			limb_connection_point = player_torso.get_parent().get_node(connection_point)
			
	if limb_connection_point == null:
		limb_connection_point = player_torso
		
	return limb_connection_point	
	
func attack_range_exited(body: Node2D):
	var data = {"raycasts": raycasts}	
	finished.emit("Enemy_Arm_Chasing",data)
