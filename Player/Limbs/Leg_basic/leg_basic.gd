extends State

var KneeMuscle 
var AnkleMuscle
var Thigh
var Calf
var Foot 
var ground_detector: Area2D
var current_connector 
var Player: Node2D 
var Torso: RigidBody2D

@onready var left_torso_muscle: DampedSpringJoint2D
@onready var right_torso_muscle: DampedSpringJoint2D

var is_grounded: bool
var torso_target: Vector2
var stiff: float
var hopping_direction:= Vector2.ZERO
var is_hopping: bool = false
var torso_inertia:int

var knee_stiffness: float
var ankle_stiffness: float
var knee_rest_length: float
var ankle_rest_length: float


func enter(previous_state_path:String,dict:= {}) -> void:
	KneeMuscle = object_reference.get_parent().get_node("KneeMuscle")
	AnkleMuscle = object_reference.get_parent().get_node("AnkleMuscle")
	Thigh = object_reference.get_parent().get_node("Thigh")
	Calf  = object_reference.get_parent().get_node("Calf")
	Foot = object_reference.get_parent().get_node("Foot")
	ground_detector = Foot.get_node("ground_detection")
	current_connector = get_parent().get_parent().get_parent()
	Player = current_connector.get_parent()
	Torso = Player.get_node("Torso")
	
	signal_setup()
	connect_torso_muscles()
	knee_stiffness = KneeMuscle.stiffness
	ankle_stiffness = AnkleMuscle.stiffness
	knee_rest_length = KneeMuscle.rest_length
	ankle_rest_length = AnkleMuscle.rest_length
	torso_inertia = 8000

func signal_setup():
	ground_detector.connect("body_entered", _on_ground_entered)
	ground_detector.connect("body_exited", _on_ground_exited)

func _on_ground_entered(body):
	if body.is_in_group("Ground"):
		is_grounded = true

func _on_ground_exited(body):
	if body.is_in_group("Ground"):
		is_grounded = false

func update(delta: float) -> void:
	if Input.is_action_pressed("w"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length
		if is_grounded:
			var jump_force = Vector2(0, -Torso.mass * 1500.0)
			Torso.apply_central_impulse(jump_force)

	elif Input.is_action_pressed("s"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length
		if is_grounded:
			var fall_force = Vector2(0, -Torso.mass * 1500.0)
			Torso.apply_central_impulse(fall_force)
		
	elif Input.is_action_just_released("s"):
		KneeMuscle.rest_length = knee_rest_length
		AnkleMuscle.rest_length = ankle_rest_length
		torso_target.y -= 100

	if Input.is_action_pressed("a"):
		hopping_direction = Vector2.LEFT
	elif Input.is_action_pressed("d"):
		hopping_direction = Vector2.RIGHT
	else:
		hopping_direction = Vector2.ZERO

func physics_update(_delta: float) -> void:
	print("Foot test" + str(Foot))
	find_torso_target()
	limit_velocity()
	balance()
	hopping()

func limit_velocity():
	var max_speed = 300.0

	if Torso.linear_velocity.length() > max_speed:
		Torso.linear_velocity = Torso.linear_velocity.normalized() * max_speed

	if Thigh.linear_velocity.length() > max_speed:
		Thigh.linear_velocity = Thigh.linear_velocity.normalized() * max_speed

	if Calf.linear_velocity.length() > max_speed:
		Calf.linear_velocity = Calf.linear_velocity.normalized() * max_speed

	if Foot.linear_velocity.length() > max_speed:
		Foot.linear_velocity = Foot.linear_velocity.normalized() * max_speed


func connect_torso_muscles():
	var current_connector_num = current_connector.name.substr(10).to_int()
	
	var connections = 0
	var connector_count = 0
	for child in Player.get_children():
		if String(child.name).begins_with("Connector "):
			connector_count += 1
		
		if connections == 2:
			break
		elif (int(String(child.name).substr(10)) == current_connector_num - 1):
			connections += 1
			var connector_joint_1 := DampedSpringJoint2D.new()
			connector_joint_1.node_a = Thigh.get_path()
			connector_joint_1.node_b = child.get_path()
			connector_joint_1.length = Thigh.global_position.distance_to(child.global_position)
			add_child(connector_joint_1)
			right_torso_muscle = connector_joint_1
			stiff = right_torso_muscle.stiffness
			
		elif (int(String(child.name).substr(10)) == current_connector_num + 1):
			connections += 1
			var connector_joint_2 := DampedSpringJoint2D.new()
			connector_joint_2.node_a = Thigh.get_path()
			connector_joint_2.node_b = child.get_path()
			connector_joint_2.length = Thigh.global_position.distance_to(child.global_position)
			add_child(connector_joint_2)
			left_torso_muscle = connector_joint_2
			break
			
	if connections == 1:
		var highest_connector = "Connector " + String(connector_count)
		var connecter_1 = "Connector 1"
		
		#for if current connector is highest number
		if current_connector_num == connector_count:
			var connector_joint_2 := DampedSpringJoint2D.new()
			connector_joint_2.node_a = Thigh.get_path()
			connector_joint_2.node_b = get_node(connecter_1).get_path()
			connector_joint_2.length = Thigh.global_position.distance_to(get_node(connecter_1).global_position)
			add_child(connector_joint_2)
			left_torso_muscle = connector_joint_2
		else:
			#if current connector is connector 1
			for child in Player.get_children():
				if child.name == highest_connector:
					var connector_joint_1 := DampedSpringJoint2D.new()
					connector_joint_1.node_a = Thigh.get_path()
					connector_joint_1.node_b = child.get_path()
					connector_joint_1.length = Thigh.global_position.distance_to(child.global_position)
					add_child(connector_joint_1)
					right_torso_muscle = connector_joint_1
					break

func find_torso_target():
	var desired_height = 500
	var target_x_offset = 50
	print("foot torso target "+str(Foot))
	target_x_offset = (((Foot.global_position.x)/abs(Foot.global_position.x)) * target_x_offset)
	
	var target_y = Foot.global_position.y - desired_height
		
	var target_x = Foot.global_position.x - target_x_offset
		
	torso_target = Vector2(target_x, target_y)

func balance():
	if !is_grounded and !is_hopping:
		left_torso_muscle.stiffness = 64
		right_torso_muscle.stiffness = 64
		left_torso_muscle.bias = 0.9
		right_torso_muscle.bias = 0.9
		left_torso_muscle.rest_length = left_torso_muscle.length
		right_torso_muscle.rest_length = left_torso_muscle.length
		left_torso_muscle.damping = 0.01
		right_torso_muscle.damping = 0.01
		return
		
	left_torso_muscle.stiffness = 0
	right_torso_muscle.stiffness = 0
	left_torso_muscle.bias = 0
	right_torso_muscle.bias = 0
	
	# Target velocity scaling (tune these)
	var max_x_speed = 100.0
	var max_y_speed = 75.0
	var gain = 120.0  # responsiveness

	# Compute distance to target
	var torso_dist = torso_target - Torso.global_position

	# Compute target velocity based on distance
	var target_velocity = Vector2(
		clamp(torso_dist.x * 0.2, -max_x_speed, max_x_speed),
		clamp(torso_dist.y * 0.2, -max_y_speed, max_y_speed)
	)

	# Calculate velocity difference
	var velocity_diff = target_velocity - Torso.linear_velocity

	# Apply central force proportional to velocity difference
	Torso.apply_central_force(velocity_diff * Torso.mass * gain)

func hopping():
	if hopping_direction == Vector2.ZERO:
		KneeMuscle.rest_length = knee_rest_length
		AnkleMuscle.rest_length = ankle_rest_length
		Torso.inertia = torso_inertia
		is_hopping = false
		return
	elif is_grounded: # and (abs(Foot.global_position.x) - abs(Torso.global_position.x) < 50 and abs(Foot.global_position.x) - abs(Torso.global_position.x) > -50):
		is_hopping = true
	
	if is_hopping:
		Torso.inertia = Torso.inertia*10
		print("hopping")
		KneeMuscle.rest_length = 40
		AnkleMuscle.rest_length = 20
		await get_tree().create_timer(0.2).timeout
		
		var hop_force = Vector2(hopping_direction.x * Torso.mass * 1000.0,0)
		Torso.apply_central_impulse(hop_force)
		await get_tree().create_timer(0.2).timeout
		
		KneeMuscle.rest_length = knee_rest_length
		AnkleMuscle.rest_length = ankle_rest_length
		is_hopping = false
		Torso.inertia = Torso.inertia/10
