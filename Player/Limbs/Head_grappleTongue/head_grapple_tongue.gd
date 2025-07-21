extends RigidBody2D
@onready var GrappleRay = $GrappleRay
@onready var Tongue = $Tongue
@onready var Anchor = $"../Anchor"
@onready var GrappleJoint = $"../GrappleJoint"

var grappling = false

func _process(delta: float) -> void:
	if not grappling and Input.is_action_just_pressed("left_mouse"):
		grappling = true
		GrappleRay.target_position = get_global_mouse_position()
		GrappleRay.force_raycast_update()
		if GrappleRay.is_colliding():
			var anchor_pos = GrappleRay.get_collision_point()
			GrappleJoint.global_position = anchor_pos
			Anchor.global_position = anchor_pos
			GrappleJoint.node_b = get_path_to(Anchor)
