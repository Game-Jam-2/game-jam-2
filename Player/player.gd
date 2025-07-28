extends Node2D

var stand_strength = 150
var roll_strength = 300
var grab_move_speed = 60000
var grab_deadzone = 20.0
var grabbing = false


@onready var torso: RigidBody2D = $Torso
@onready var sockets := {
	"1": $"Connector 1",
	"2": $"Connector 2",
	"3": $"Connector 3",
	"4": $"Connector 4",
	"5": $"Connector 5"
}

# Swap this for testing limb scene
var current_limb_scene: PackedScene
var Head: PackedScene = preload("res://Player/Limbs/Head_grappleTongue/Head_grappleTongue.tscn")
var Arm: PackedScene = preload("res://Player/Limbs/Arm_Katana/arm_katana.tscn")
var Leg: PackedScene = preload("res://Player/Limbs/Leg_basic/leg_basic.tscn")

var current_limb: Node = null

func _ready() -> void:
	current_limb = torso

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		current_limb_scene = Head
	if Input.is_action_just_pressed("2") or Input.is_action_just_pressed("5"):
		current_limb_scene = Arm
	if Input.is_action_just_pressed("3") or Input.is_action_just_pressed("4"):
		current_limb_scene = Leg
		
	for key in ["1", "2", "3", "4", "5"]:
		if Input.is_action_just_pressed(key):
			_attach_limb_to_slot(key)


func _physics_process(delta: float) -> void:
	if current_limb and current_limb.has_method("physics_update"):
		current_limb.physics_update(delta)
	
	if current_limb == torso:
		if Input.is_action_pressed("d"):
			if torso.linear_velocity.x <= 30:
				torso.apply_central_impulse(Vector2.UP * stand_strength)
			torso.apply_central_impulse(Vector2.RIGHT * roll_strength)
		if Input.is_action_pressed("a"):
			if torso.linear_velocity.x >= -30:
				torso.apply_central_impulse(Vector2.UP * stand_strength)
			torso.apply_central_impulse(Vector2.LEFT * roll_strength)
	
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

	var joint = PinJoint2D.new()
	joint.node_a = slot.get_path()
	joint.node_b = limb.get_child(0).get_path()
	joint.global_position = slot.global_position
	get_parent().add_child(joint)
	connect_grabbing_signals(limb)

	current_limb = limb
	
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
	print("grab released")

func grab_movement():
	if grabbing:
		var target_pos = get_global_mouse_position()
		var to_target = target_pos - torso.global_position
		var distance = to_target.length()

		if distance > grab_deadzone:
			var direction = to_target.normalized()
			torso.apply_central_force(direction * grab_move_speed)
			if abs(torso.linear_velocity.length()) > 750:
				torso.linear_velocity *= 0.5
		else:
			torso.linear_velocity = torso.linear_velocity * 0.8
