extends Control
var limb_idle: bool = false
var limb_equipped: bool = false
var scene_name: String
var socket: String
@onready var Player: Node = get_parent().get_parent()
@onready var LimbDetector: Node = Player.get_node("Torso").get_node("LimbDetector")

@onready var head_button = $Head
@onready var Left_Arm_button = $"Left Arm"
@onready var Right_Arm_button = $"Right Arm"
@onready var Left_Leg_button = $"Left Leg"
@onready var Right_Leg_button = $"Right Leg"

signal limb_sent

func _ready() -> void:
	var player = get_parent().get_parent()
	player.connect("dettach_limb_sent", limb_dettached)
	head_button.connect("button_down", head)
	Left_Arm_button.connect("button_down", left_arm)
	Right_Arm_button.connect("button_down", right_arm)
	Left_Leg_button.connect("button_down", left_leg)
	Right_Leg_button.connect("button_down", right_leg)
	
func head():
	socket = "Head"
	send_limb_info()
func left_arm():
	socket = "Left Arm"
	send_limb_info()
func right_arm():
	socket = "Right Arm"
	send_limb_info()
func left_leg():
	socket = "Left Leg"
	send_limb_info()
func right_leg():
	socket = "Right Leg"
	send_limb_info()

func _process(delta: float) -> void:
	check_connectors()
	if Input.is_action_just_pressed("equip limb") and !limb_equipped:
		for body in LimbDetector.get_overlapping_bodies():
			var limb = body.get_parent()
			if limb and limb.is_in_group("Limbs"):
				var state = limb.get_node("StateMachine").current_state
				var idle_state = limb.get_node("StateMachine").get_node(limb.name + "_Idle")
				if state == idle_state:
					scene_name = "res://Player/Limbs/" + limb.name + "/" + limb.name + ".tscn"
					visible = true
					limb.queue_free()
					get_tree().paused = true
					limb_equipped = true
					break

func send_limb_info() -> void:
	limb_sent.emit(scene_name, socket)
	visible = false
	get_tree().paused = false

func limb_dettached():
	limb_equipped = false

func check_connectors():
	if !Player.get_node("Connector 1"):
		head_button.visible = false
	else:
		head_button.visible = true
	
	if !Player.get_node("Connector 2"):
		Right_Arm_button.visible = false
	else:
		Right_Arm_button.visible = true
	
	if !Player.get_node("Connector 3"):
		Right_Leg_button.visible = false
	else:
		Right_Leg_button.visible = true
	
	if !Player.get_node("Connector 4"):
		Left_Leg_button.visible = false
	else:
		Left_Leg_button.visible = true
	
	if !Player.get_node("Connector 5"):
		Left_Arm_button.visible = false
	else:
		Left_Arm_button.visible = true
		
		
