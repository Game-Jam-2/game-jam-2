extends Node2D

var roll_strength = 60
var grab_move_speed = 30000
var grab_deadzone = 5.0
var grabbing = false
var incoming_limb: Node = null

@onready var LimbGUI: Control = $CanvasLayer/LimbGUI
@onready var LimbDetector = $Torso/LimbDetector
@onready var torso: RigidBody2D = $Torso
@onready var sockets := {
	"Head": $"Connector 1",
	"Right Arm": $"Connector 2",
	"Right Leg": $"Connector 3",
	"Left Leg": $"Connector 4",
	"Left Arm": $"Connector 5"
}

var current_limb_scene: PackedScene

var current_limb: Node = null
var limb_attached: bool = false

func _ready() -> void:
	LimbGUI.connect("limb_sent", limb_recieved)
	current_limb = torso

func limb_recieved(scene_name, socket):
	current_limb_scene = load(scene_name)
	_attach_limb_to_slot(socket)


func _physics_process(delta: float) -> void:
	if current_limb and current_limb.has_method("physics_update"):
		current_limb.physics_update(delta)
	
	if !limb_attached:
		if Input.is_action_pressed("d"):
			torso.apply_central_impulse(Vector2.RIGHT * roll_strength)
		if Input.is_action_pressed("a"):
			torso.apply_central_impulse(Vector2.LEFT * roll_strength)
	
	elif Input.is_action_just_pressed("equip limb") and limb_attached:
		dettach_limb()
		
	grab_movement()

func _attach_limb_to_slot(key: String) -> void:
	var slot = sockets.get(key)

	if not slot or slot.get_child_count() > 1:
		return

	# 🧪 Utter witchcraft – do not touch
	var limb = current_limb_scene.instantiate()
	var limb_rigid_bodies:Array[Node] = limb.get_children() 

			
	slot.add_child(limb)
	limb.global_position = slot.global_position
	var equip_state = "Equipping"

	var joint = PinJoint2D.new()
	joint.node_a = slot.get_path()
	joint.node_b = limb.get_child(0).get_path()
	joint.global_position = slot.global_position
	joint.softness = 0
	get_parent().add_child(joint)
	connect_grabbing_signals(limb)
	print(equip_state)
	limb.get_node("StateMachine")._transistion_to_next_state(equip_state, {})
	limb_attached = true
	current_limb = limb

func dettach_limb():
	for child in get_parent().get_children():
		if child is PinJoint2D:
			print("limb dettached:", child)
			child.queue_free()
	current_limb.get_node("StateMachine")._transistion_to_next_state(current_limb.name + "_Idle", {})
	current_limb = torso
	limb_attached = false


func connect_grabbing_signals(node):
	if node.has_signal("grabbing"):
		if not node.is_connected("grabbing", limb_grabbing):
			node.connect("grabbing", limb_grabbing)
	if node.has_signal("releasing"):
		if not node.is_connected("releasing", limb_ungrabbing):
			node.connect("releasing", limb_ungrabbing)
	
	for child in node.get_children():
		connect_grabbing_signals(child)


func limb_grabbing():
	grabbing = true
func limb_ungrabbing():
	grabbing = false

func grab_movement():
	if grabbing:
		var target_pos = get_global_mouse_position()
		var to_target = target_pos - torso.global_position
		var distance = to_target.length()

		if distance > grab_deadzone:
			var direction = to_target.normalized()
			torso.apply_central_force(direction * -grab_move_speed)
			if abs(torso.linear_velocity.length()) > 750:
				torso.linear_velocity *= 0.5
		else:
			torso.linear_velocity = torso.linear_velocity * 0.8
