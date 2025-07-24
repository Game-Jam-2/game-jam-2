extends Node2D

@onready var KneeMuscle = $KneeMuscle
@onready var AnkleMuscle = $AnkleMuscle
@onready var Thigh = $Thigh
@onready var current_connector: RigidBody2D = get_parent()
@onready var Player: Node2D = current_connector.get_parent()

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
	
	# Tilt control with velocity clamping
	var velocity = Thigh.linear_velocity

	if Input.is_action_pressed("a"):
		velocity.x = max(velocity.x - tilt_force, -max_tilt_speed)
	elif Input.is_action_pressed("d"):
		velocity.x = min(velocity.x + tilt_force, max_tilt_speed)

	Thigh.linear_velocity = velocity

func connect_torso_muscles():
	var current_connector_num = int(String(current_connector.name).substr(10))
	current_connector_num = int(current_connector_num)
	print(current_connector_num)
	
	var connections = 0
	var connector_count = 0
	for child in Player.get_children():
		if String(child.name).begins_with("Connector "):
			connector_count += 1
		
		if connections == 2:
			break
		elif (int(String(child.name).substr(10)) == current_connector_num + 1):
			connections += 1
			var connector_joint_1 := DampedSpringJoint2D.new()
			connector_joint_1.node_a = Thigh.get_path()
			connector_joint_1.node_b = child.get_path()
			connector_joint_1.length = Thigh.global_position.distance_to(child.global_position)
			add_child(connector_joint_1)
			
			#break early if we know theres no connector lower
			if current_connector_num == 1:
				break
			
		elif (int(String(child.name).substr(10)) == current_connector_num - 1):
			connections += 1
			var connector_joint_2 := DampedSpringJoint2D.new()
			connector_joint_2.node_a = Thigh.get_path()
			connector_joint_2.node_b = child.get_path()
			connector_joint_2.length = Thigh.global_position.distance_to(child.global_position)
			add_child(connector_joint_2)
			
	if connections == 1:
		var connect_to = "Connector " + String(connector_count)
		for child in Player.get_children():
			if child.name == connect_to:
				var connector_joint_2 := DampedSpringJoint2D.new()
				connector_joint_2.node_a = Thigh.get_path()
				connector_joint_2.node_b = child.get_path()
				connector_joint_2.length = Thigh.global_position.distance_to(child.global_position)
				add_child(connector_joint_2)
