extends Control
var limb: Node
var limb_idle: bool = false
var limb_available: bool = false
var limb_attached: bool = false
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
	LimbDetector.connect("body_entered", _on_limb_equipped)
	LimbDetector.connect("body_exited", _limb_left_radius)
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
	if limb_available and Input.is_action_just_pressed("equip limb") and !limb_attached:
		var state = limb.get_node("StateMachine").current_state
		var idle_state = limb.get_node("StateMachine").get_node(limb.name + "_Idle")
		if state == idle_state:
			scene_name = "res://Player/Limbs/" + limb.name + "/" + limb.name + ".tscn"
			visible = true
			limb.queue_free()
			get_tree().paused = true
	elif Input.is_action_just_pressed("equip limb") and limb_attached:
		for child in Player.get_children():
			if "Connector" in child.name:
				if child.get_child_count() > 1:
					var idle_state = limb.get_node("StateMachine").get_node(limb.name + "_Idle")


func _on_limb_equipped(body: Node) -> void:
	if body.get_parent():
		if body.get_parent().is_in_group("Limbs"):
			limb = body.get_parent()
			print("limb:", limb)
			limb_available = true

func _limb_left_radius(body: Node) -> void:
	if body.get_parent():
		if body.get_parent().is_in_group("Limbs"):
			limb_available = false

func send_limb_info() -> void:
	limb_sent.emit(scene_name, socket)
	visible = false
	limb_attached = true
	print("limb:", scene_name)
	get_tree().paused = false
