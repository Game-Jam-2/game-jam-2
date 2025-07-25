extends Node2D

@onready var KneeMuscle = $KneeMuscle
@onready var AnkleMuscle = $AnkleMuscle
@onready var Thigh = $Thigh
@onready var Calf = $Calf
@onready var Foot = $Foot
@onready var ground_detector: Area2D = $Foot/ground_detection
@onready var current_connector: RigidBody2D = get_parent()
@onready var Player: Node2D = current_connector.get_parent()
@onready var Torso: RigidBody2D = Player.get_node("Torso")
@onready var left_torso_muscle: DampedSpringJoint2D
@onready var right_torso_muscle: DampedSpringJoint2D

var is_grounded: bool
var torso_target: Vector2
var stiff: float

var knee_stiffness: float
var ankle_stiffness: float
var knee_rest_length: float
var ankle_rest_length: float


func _ready() -> void:
	signal_setup()
	connect_torso_muscles()
	knee_stiffness = KneeMuscle.stiffness
	ankle_stiffness = AnkleMuscle.stiffness
	knee_rest_length = KneeMuscle.rest_length
	ankle_rest_length = AnkleMuscle.rest_length

func signal_setup():
	ground_detector.connect("body_entered", _on_ground_entered)
	ground_detector.connect("body_exited", _on_ground_exited)

func _on_ground_entered(body):
	if body.is_in_group("Ground"):
		is_grounded = true

func _on_ground_exited(body):
	if body.is_in_group("Ground"):
		is_grounded = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("w"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length
		if is_grounded:
			#accumulates as long as grounded, adding force upward to begin jump, and once not grounded, release impulse
			#this simulates bending leg to jump higher
			pass

	elif Input.is_action_just_released("w"):
		KneeMuscle.stiffness = knee_stiffness
		AnkleMuscle.stiffness = ankle_stiffness


	elif Input.is_action_pressed("s"):
		print(KneeMuscle.rest_length)
		print(AnkleMuscle.rest_length)
		KneeMuscle.rest_length = 60
		AnkleMuscle.rest_length = 30
		
	elif Input.is_action_just_released("s"):
		KneeMuscle.rest_length = knee_rest_length
		AnkleMuscle.rest_length = ankle_rest_length
		torso_target.y -= 100

	if Input.is_action_pressed("a"):
		Torso.apply_central_force(Vector2(-1000,20))
		Foot.apply_central_force(Vector2(-20,20))
	elif Input.is_action_pressed("d"):
		Torso.apply_central_force(Vector2(1000,200))
		Foot.apply_central_force(Vector2(20,200))

func _physics_process(delta: float) -> void:
	find_torso_target()
	limit_velocity()
	balance()

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
		
	target_x_offset = ((Foot.global_position.x/abs(Foot.global_position.x)) * target_x_offset)
		
	var target_y = Foot.global_position.y - desired_height
		
	var target_x = Foot.global_position.x - target_x_offset
		
	torso_target = Vector2(target_x, target_y)

func balance():
	if !is_grounded:
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
