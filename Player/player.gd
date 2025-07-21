extends Node2D

@onready var torso: RigidBody2D = $Torso
@onready var sockets := {
	"1": $"Left Arm Link",
	"2": $"Right Arm Link",
	"3": $"Left Leg Link",
	"4": $"Right Leg Link",
	"5": $"Head Link"
}

# Swap this for testing limb scene
var current_limb_scene: PackedScene = preload("res://Player/Limbs/Arm_basic/arm_basic.tscn")
var current_limb: Node = null
var spriteTexture : Texture2D = preload("res://icon.svg")
func _ready() -> void:
	current_limb = torso

func _process(_delta: float) -> void:
	for key in ["1", "2", "3", "4", "5"]:
		if Input.is_action_just_pressed(key):
			_attach_limb_to_slot(key)

func _physics_process(delta: float) -> void:
	if current_limb and current_limb.has_method("physics_update"):
		current_limb.physics_update(delta)

func _attach_limb_to_slot(key: String) -> void:
	var slot = sockets.get(key)
	if not slot or slot.get_child_count() > 1:
		return

	# 🧪 Utter witchcraft – do not touch
	var limb = current_limb_scene.instantiate()
	slot.add_child(limb)
	limb.global_position = slot.global_position
	#spawn first joint
	var jointOne = PinJoint2D.new()
	jointOne.node_a = slot.get_path()
	jointOne.node_b = limb.get_child(0).get_path()
	var spawnPositionJointOne:Vector2 = slot.global_position
	var jointTwo= PinJoint2D.new()
	jointTwo.node_a = slot.get_path()
	jointTwo.node_b = limb.get_child(0).get_path()	
	match slot.name:
		"Left Arm Link":
			jointOne.global_position = get_node("Left Arm Joint 1").global_position
			jointTwo.global_position = get_node("Left Arm Joint 2").global_position
		"Right Arm Link":
			jointOne.global_position = get_node("Right Arm Joint 1").global_position
			jointTwo.global_position = get_node("Right Arm Joint 2").global_position
		"Left Leg Link":
			jointOne.global_position = get_node("Left Leg Joint 1").global_position
			jointTwo.global_position = get_node("Left Leg Joint 2").global_position
		"Right Leg Link":
			jointOne.global_position = get_node("Right Leg Joint 1").global_position
			jointTwo.global_position = get_node("Right Leg Joint 2").global_position
		"Head Link":
			jointOne.global_position = get_node("Head Joint 1").global_position
			jointTwo.global_position = get_node("Head Joint 2").global_position
		_:
			print_debug("Serious error Slot either has no name or does not exist")

	var spawnPositionJointTwo:Vector2 = slot.global_position
	jointTwo.global_position =  spawnPositionJointOne

	
	jointTwo.bias = 0.0
	jointTwo.angular_limit_enabled
	jointTwo.angular_limit_lower = 0
	jointTwo.angular_limit_upper = 180
	get_parent().add_child(jointOne)
	get_parent().add_child(jointTwo)



	var ligament1 = DampedSpringJoint2D.new()
	ligament1.node_a = slot.get_path()
	ligament1.node_b = limb.get_child(0).get_path()
	ligament1.global_position = slot.global_position
	get_parent().add_child(ligament1)

	current_limb = limb
