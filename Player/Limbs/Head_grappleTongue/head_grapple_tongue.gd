extends RigidBody2D

@onready var GrappleRay = $GrappleRay
@onready var Tongue = $Tongue
@onready var Anchor = $"../Anchor"
@onready var GrappleJoint: DampedSpringJoint2D = $"../GrappleJoint"
@onready var AnchorMark = $"../Anchor/Anchor Mark"

var grappling = false
var anchor_pos = Vector2.ZERO
var reel_force = 600.0
var swing_force = 400.0
var reel_speed = 100.0
var min_rope_length = 0.0
var max_rope_length = 800.0

func _process(delta: float) -> void:
	if not grappling and Input.is_action_just_pressed("left_mouse"):
		GrappleJoint.length = 10
		GrappleRay.target_position = to_local(get_global_mouse_position())
		GrappleRay.force_raycast_update()
		
		if GrappleRay.is_colliding():
			Anchor.visible = true
			grappling = true
			anchor_pos = GrappleRay.get_collision_point()
			GrappleJoint.node_b = get_path_to(Anchor)
			Anchor.global_position = anchor_pos
			GrappleJoint.global_position = anchor_pos
			GrappleJoint.node_b = get_path_to(Anchor)
	
	elif Input.is_action_just_released("left_mouse"):
		grappling = false
		Anchor.visible = false
		GrappleJoint.node_b = NodePath("")
		anchor_pos = Vector2.ZERO
	
	elif anchor_pos != Vector2.ZERO:
		GrappleJoint.global_position = anchor_pos
		Anchor.global_position = anchor_pos

	Tongue.clear_points()
	if grappling:
		Tongue.add_point(Vector2.ZERO)
		Tongue.add_point(to_local(AnchorMark.global_position))

		if Input.is_action_pressed("w"):
			var dir_to_anchor = (anchor_pos - global_position).normalized()
			apply_force(dir_to_anchor * reel_force)
			GrappleJoint.length = max(min_rope_length, GrappleJoint.length - reel_speed * delta)

		if Input.is_action_pressed("s"):
			var dir_away = (global_position - anchor_pos).normalized()
			apply_force(dir_away * reel_force)
			GrappleJoint.length = min(max_rope_length, GrappleJoint.length + reel_speed * delta)


		if Input.is_action_pressed("a"):
			var to_anchor = anchor_pos - global_position
			var right = Vector2(to_anchor.y, -to_anchor.x).normalized()
			apply_force(right * swing_force)
			
		if Input.is_action_pressed("d"):
					var to_anchor = anchor_pos - global_position
					var left = Vector2(-to_anchor.y, to_anchor.x).normalized()
					apply_force(left * swing_force)
