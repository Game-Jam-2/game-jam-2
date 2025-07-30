extends State
var raycasts : Array[RayCast2D]
var player_torso:RigidBody2D
var connecter_regex: RegEx = RegEx.new()
var player_limb:RigidBody2D
var first_entry:bool = true
var speed:int = 500
var hand:RigidBody2D
var limb_root: RigidBody2D
var torso:RigidBody2D
var hand_boost:int = 100
var grabbing:bool = false
var swing_pin:PinJoint2D
var root_node:Node2D
var first:bool
var grab_point:RigidBody2D
func enter(previous_state_path: String,data := {}):
	root_node = object_reference.get_parent().get_parent().get_parent().get_parent()
	torso = object_reference.get_parent().get_parent().get_parent().get_node("Torso")
	hand = object_reference.get_parent().get_node("Hand")
	grab_point = object_reference.get_parent().get_node("Grab Point")
	assert(torso.name == "Torso")
	assert(hand.name == "Hand")
	assert(grab_point.name == "Grab Point")
	torso.linear_velocity = Vector2.ZERO
	hand.linear_velocity = Vector2.ZERO
	if first:
		grab_point.body_entered.connect(hand_collided)
		first = false

	if first_entry:
		print(hand.get_parent().get_parent().get_parent().get_node("Torso").get_node("Attack_Range"))
		hand.get_parent().get_parent().get_parent().get_node("Torso").get_node("Attack_Range").body_exited.connect(attack_range_exited)
		raycasts = data["raycasts"]
		player_torso = data["player_torso"]
		connecter_regex.compile("Connector \\d")
		first_entry = false
		

func physics_update(delta: float) -> void:
	limb_root =  get_player_limb()
	if limb_root.name != "Torso":
		remove_torso_collision_mask()
		player_limb = get_player_limb().get_child(1).get_child(0)	
	else:
		add_torso_collision_mask()		
		player_limb = limb_root
				
	var direction:Vector2 = (player_limb.global_position - hand.global_position)
	

	var force:Vector2 = direction * speed * delta
	
	if grabbing:
		grab()
		torso.apply_force(force * hand_boost * -1)
		hand.apply_force(force * hand_boost  * -1)
	else:
		hand.apply_force(force * hand_boost)
		
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

func hand_collided(body:RigidBody2D):
	if body.is_in_group("Limb") or body.name == "Torso":
		grabbing = true
		print("BODY COLLIDED " + str(body))
	print("IRRELEVANT BODY" + str(body))
	
	

	
#grabs onto the floor 
func grab() -> void:
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(hand.get_path())
	swing_pin.set_node_b(player_limb.get_path())
	swing_pin.bias = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	hand.get_parent().get_parent().add_child(root_node)
	
func add_torso_collision_mask() -> void:
	for child in object_reference.get_parent().get_children():
		if child is RigidBody2D:
			child.set_collision_mask_value(1,true)
			print(child.get_collision_layer_value(1))

			
func remove_torso_collision_mask() -> void:
	for child in object_reference.get_parent().get_children():
		if child is RigidBody2D:
			child.set_collision_mask_value(1,false)
