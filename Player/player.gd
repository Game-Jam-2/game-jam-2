extends Node2D

@onready var torso: RigidBody2D = $Torso

@onready var sockets := {
	"1": $"Left Arm Link",
	"2": $"Right Arm Link",
	"3": $"Left Leg Link",
	"4": $"Right Leg Link",
}

# swap this for testing limb scene
var current_limb_scene: PackedScene = preload("res://Player/Limbs/Leg_basic/leg_basic.tscn")
var current_limb: Node = null


func _ready() -> void:
	current_limb = torso

func _process(_delta: float) -> void:
	for key in ["1", "2", "3", "4"]:
		if Input.is_action_just_pressed(key):
			_attach_limb_to_slot(key)

func _physics_process(delta: float) -> void:
	if current_limb and current_limb.has_method("physics_update"):
		current_limb.physics_update(delta)

func _attach_limb_to_slot(key: String) -> void:
	var slot = sockets.get(key)
	if not slot or slot.get_child_count() > 1:
		return
	##utter witchcraft do not touch
	var limb = current_limb_scene.instantiate()
	slot.add_child(limb)
	limb.global_position = slot.global_position
	var joint =  PinJoint2D.new()
	joint.node_a = slot.get_path()
	joint.node_b = limb.get_node("Hip").get_path()
	joint.global_position = slot.global_position 
	joint.bias = 0.0
	joint.angular_limit_enabled
	joint.angular_limit_lower = 0
	joint.angular_limit_upper = 180
	get_parent().add_child(joint)
	current_limb = limb
