extends Node2D

@onready var KneeMuscle = $KneeMuscle
@onready var AnkleMuscle = $AnkleMuscle
@onready var Thigh = $Thigh
@onready var Foot = $Foot
@onready var current_connector: RigidBody2D = get_parent()
@onready var Player: Node2D = current_connector.get_parent()
@onready var Torso: RigidBody2D = Player.get_node("Torso")
@onready var left_torso_muscle: DampedSpringJoint2D
@onready var right_torso_muscle: DampedSpringJoint2D

var tilt_force := 1.0
var max_tilt_speed := 100.0

var knee_stiffness: float
var ankle_stiffness: float
var knee_rest_length: float
var ankle_rest_length: float

func _ready() -> void:
	connect_torso_muscles()
	knee_stiffness = KneeMuscle.stiffness
	ankle_stiffness = AnkleMuscle.stiffness
	knee_rest_length = KneeMuscle.rest_length
	ankle_rest_length = AnkleMuscle.rest_length

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("w"):
		KneeMuscle.stiffness = 64
		AnkleMuscle.stiffness = 64
		KneeMuscle.rest_length = KneeMuscle.length
		AnkleMuscle.rest_length = AnkleMuscle.length

	elif Input.is_action_just_released("w"):
		KneeMuscle.stiffness = knee_stiffness
		AnkleMuscle.stiffness = ankle_stiffness

	elif Input.is_action_pressed("s"):
		KneeMuscle.rest_length = 5
		AnkleMuscle.rest_length = 5
		await get_tree().create_timer(1).timeout
		KneeMuscle.rest_length = knee_rest_length
		AnkleMuscle.rest_length = ankle_rest_length

	if Input.is_action_pressed("a"):
		
		pass
	elif Input.is_action_pressed("d"):
		
		pass

func _physics_process(delta: float) -> void:
	if is_torso_upright():
		balance_torso_to_upright()
	else:
		stand_up()

func is_torso_upright() -> bool:
	var angle_deg = rad_to_deg(Torso.rotation)
	return abs(angle_deg) < 45

func connect_torso_muscles():
	var current_connector_num = current_connector.name.substr(10).to_int()
	print(current_connector_num)
	
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

func balance_torso_to_upright():
	var torso_pos = Player.global_position
	var foot_pos = Foot.global_position
	var x_diff = torso_pos.x - foot_pos.x
	var abs_diff = abs(x_diff)

	var balance_factor = clamp(abs_diff / 100.0, 0.0, 1.0)
	var length_adjust = lerp(0.0, 10.0, balance_factor)
	
	if x_diff > 5:
		# torso too far right
		left_torso_muscle.rest_length = max(left_torso_muscle.rest_length - length_adjust, 5.0)
		right_torso_muscle.rest_length = min(right_torso_muscle.rest_length + length_adjust, 100.0)
	elif x_diff < -5:
		# torso too far left
		right_torso_muscle.rest_length = max(right_torso_muscle.rest_length - length_adjust, 5.0)
		left_torso_muscle.rest_length = min(left_torso_muscle.rest_length + length_adjust, 100.0)

	var target_stiffness = lerp(10.0, 100.0, balance_factor)
	left_torso_muscle.stiffness = target_stiffness
	right_torso_muscle.stiffness = target_stiffness
	
func stand_up():
	left_torso_muscle.stiffness = 0
	right_torso_muscle.stiffness = 0
	left_torso_muscle.damping = 0
	right_torso_muscle.damping = 0
	
	var target_x = Player.global_position.x
	var foot_x = Foot.global_position.x
	var move_direction = sign(target_x - foot_x)

	KneeMuscle.stiffness = 60
	AnkleMuscle.stiffness = 60

	var attempts := 0
	while abs(Foot.global_position.x - target_x) > 5.0 and attempts < 30:
		KneeMuscle.rest_length -= move_direction * 0.5
		AnkleMuscle.rest_length += move_direction * 0.5
		await get_tree().create_timer(0.05).timeout
		attempts += 1

	KneeMuscle.rest_length = knee_rest_length
	AnkleMuscle.rest_length = ankle_rest_length
	KneeMuscle.stiffness = 100
	AnkleMuscle.stiffness = 100

	Torso.apply_impulse(Vector2(0, -200))
	Torso.apply_torque_impulse(-Torso.rotation * 500)
	await get_tree().create_timer(0.4).timeout

	left_torso_muscle.stiffness = 40
	right_torso_muscle.stiffness = 40
	left_torso_muscle.damping = 10
	right_torso_muscle.damping = 10
