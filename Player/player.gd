extends Node2D

@onready var torso: RigidBody2D = $Torso

@onready var sockets := {
	"1": $"Left Arm Link",
	"2": $"Right Arm Link",
	"3": $"Left Leg Link",
	"4": $"Right Leg Link",
}

# swap this for testing limb scene
var current_limb_scene: PackedScene = preload("res://Player/player.tscn")
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

	var limb = current_limb_scene.instantiate()
	slot.add_child(limb)
	limb.global_position = slot.global_position

	if limb.has_method("setup_joint"):
		var joint = DampedSpringJoint2D.new()
		joint.set_node_a(slot.get_path())
		joint.set_node_b(limb.get_node("Thigh").get_path())
		joint.length = 1
		joint.stiffness = 64
		joint.damping = 16
		print(joint.length)
		add_child(joint)
		print("break")

	current_limb = limb
