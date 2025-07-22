extends Node2D

var stand_strength = 150
var roll_strength = 75


@onready var torso: RigidBody2D = $Torso
@onready var sockets := {
	"1": $"Left Arm Link",
	"2": $"Right Arm Link",
	"3": $"Left Leg Link",
	"4": $"Right Leg Link",
	"5": $"Head Link"
}

# Swap this for testing limb scene
var current_limb_scene: PackedScene
var Head: PackedScene = preload("res://Player/Limbs/Head_basic/Head_basic.tscn")
var Arm: PackedScene = preload("res://Player/Limbs/Arm_basic/arm_basic.tscn")
var Leg: PackedScene = preload("res://Player/Limbs/Leg_basic/leg_basic.tscn")

var current_limb: Node = null

func _ready() -> void:
	current_limb = torso

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("5"):
		current_limb_scene = Head
	if Input.is_action_just_pressed("1") or Input.is_action_just_pressed("2"):
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
				print("getting up")
			torso.apply_central_impulse(Vector2.RIGHT * roll_strength)
		if Input.is_action_pressed("a"):
			if torso.linear_velocity.x >= -30:
				torso.apply_central_impulse(Vector2.UP * stand_strength)
				print("getting up")
			torso.apply_central_impulse(Vector2.LEFT * roll_strength)
		

func _attach_limb_to_slot(key: String) -> void:
	var slot = sockets.get(key)
	if not slot or slot.get_child_count() > 1:
		return

	# 🧪 Utter witchcraft – do not touch
	var limb = current_limb_scene.instantiate()
	slot.add_child(limb)
	limb.global_position = slot.global_position

	var joint = PinJoint2D.new()
	joint.node_a = slot.get_path()
	joint.node_b = limb.get_child(0).get_path()
	joint.global_position = slot.global_position
	get_parent().add_child(joint)


	current_limb = limb
