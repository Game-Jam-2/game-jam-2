extends Node2D

@onready var torso: RigidBody2D = $Torso

@onready var sockets := {
	"1": $LeftArm_Socket,
	"2": $RightArm_Socket,
	"3": $LeftLeg_Socket,
	"4": $RightLeg_Socket,
}

# swap this for testing limb scene
var current_limb_scene: PackedScene = preload("res://Player/Limbs/Leg_basic/leg_basic.tscn")

var current_limb: Node = null

func _ready() -> void:
	current_limb = torso

func _process(_delta: float) -> void:
	for key in ["1", "2", "3", "4"]:
		if Input.is_action_just_pressed(key) and current_limb != torso:
			_attach_limb_to_slot(key)

func _physics_process(delta: float) -> void:
	if current_limb and current_limb.has_method("physics_update"):
		current_limb.physics_update(delta)

func _attach_limb_to_slot(key: String) -> void:
	var slot = sockets.get(key)
	if not slot or slot.get_child_count() > 0:
		return

	var limb = current_limb_scene.instantiate()
	slot.add_child(limb)
	limb.global_position = slot.global_position

	if limb.has_method("setup_joint"):
		limb.setup_joint(slot, slot.global_position)


	current_limb = limb
