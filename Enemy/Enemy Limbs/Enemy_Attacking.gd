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
func enter(previous_state_path: String,data := {}):
	root_node = object_reference.get_parent().get_parent().get_parent().get_parent()
	torso = object_reference.get_parent().get_parent().get_parent().get_node("Torso")
	hand = object_reference.get_parent().get_node("Hand")
	assert(torso.name == "Torso")
	assert(hand.name == "Hand")
	torso.linear_velocity = Vector2.ZERO
	hand.linear_velocity = Vector2.ZERO
	
	hand.body_entered.connect(hand_collided)
	hand.body_exited.connect(hand_uncollided)
	

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
			player_limb = get_player_limb().get_child(1).get_child(0)	
	else:
		player_limb = limb_root
				
	var direction:Vector2 = (player_limb.global_position - hand.global_position)
	

	var force:Vector2 = direction * speed * delta
	hand.apply_force(force * hand_boost)
	if grabbing:
		grab()
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
		
	
func hand_uncollided(body:RigidBody2D):
	if body.is_in_group("Limb") or body.name == "Torso":
		grabbing = false
	
#grabs onto the floor 
func grab() -> void:
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(hand.get_path())
	swing_pin.set_node_b(player_limb.get_path())
	swing_pin.bias = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	hand.get_parent().get_parent().add_child(root_node)
	
