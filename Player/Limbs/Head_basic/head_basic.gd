extends Node2D

@onready var body: RigidBody2D = $Head
@onready var floor_ray: RayCast2D = $FloorRay

var hovering = false

var hover_height = 700.0
var def_hover_height = 700.0 #make same as hover_height
var hover_force = 370.0
var tilt_force = 700.0
var ascend_force = 180.0
var max_hover_velocity = 200.0

func _physics_process(delta):
	hover()
	input()

func hover():
	if floor_ray.is_colliding() and hovering:
		var distance_to_floor = floor_ray.get_collision_point().y - body.global_position.y
		if distance_to_floor < hover_height:
			if body.linear_velocity.y > -max_hover_velocity:
				body.apply_central_impulse(Vector2.UP * hover_force * (1.0 - distance_to_floor / hover_height))

func input():
	if Input.is_action_pressed("a") and hovering:
		body.apply_central_impulse(Vector2.LEFT * ascend_force)
	if Input.is_action_pressed("d") and hovering:
		body.apply_central_impulse(Vector2.RIGHT * ascend_force)

	if Input.is_action_pressed("w") or Input.is_action_pressed("space"):
		hovering = true
		body.apply_central_impulse(Vector2.UP * ascend_force)
	
	if Input.is_action_pressed("s"):
		hovering = false
		
