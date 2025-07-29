extends State

var head: RigidBody2D 
var floor_ray: RayCast2D 

var hovering = false

var hover_height = 700.0
var def_hover_height = 700.0 #make same as hover_height
var hover_force = 370.0
var tilt_force = 700.0
var ascend_force = 180.0
var max_hover_velocity = 200.0
func enter(previous_state_path:String,data:= {}):
	floor_ray = object_reference.get_parent().get_node("FloorRay")
	head =  object_reference.get_parent().get_node("Head")

func physics_update(_delta:float):
	hover()

func hover():
	if floor_ray.is_colliding() and hovering:
		var distance_to_floor = floor_ray.get_collision_point().y - head.global_position.y
		if distance_to_floor < hover_height:
			if head.linear_velocity.y > -max_hover_velocity:
				head.apply_central_impulse(Vector2.UP * hover_force * (1.0 - distance_to_floor / hover_height))

func handle_input(_event:InputEvent):
	if Input.is_action_pressed("a") and hovering:
		head.apply_central_impulse(Vector2.LEFT * ascend_force)
	if Input.is_action_pressed("d") and hovering:
		head.apply_central_impulse(Vector2.RIGHT * ascend_force)

	if Input.is_action_pressed("w") or Input.is_action_pressed("space"):
		hovering = true
		head.apply_central_impulse(Vector2.UP * ascend_force)
	
	if Input.is_action_pressed("s"):
		hovering = false
		
