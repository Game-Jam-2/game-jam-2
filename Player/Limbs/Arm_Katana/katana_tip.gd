extends State

var swing_pin 

signal grabbing
signal releasing

var anchor: Vector2
var hooked = false
var hook_threshold = 10.0
var tips_in = false
var Katana_pos: Vector2
var hook_body: Node
var katana:RigidBody2D
var katana_tip:Area2D
var thrust_cooldown: bool
var thrusting: bool = false
var thrusting_time: bool = false

var thrust_force = 7500
var move_speed = 1000
var deadzone = 2.0

func enter(orevious_state_path:String,dict := {}):
	katana = get_parent().get_parent().get_node("Katana")
	katana_tip = katana.get_node("Katana Stab Detector")
	katana_tip.connect("body_entered", _on_body_entered)
	katana_tip.connect("body_exited", _on_body_exited)
	swing_pin = get_parent().get_parent().get_node("swing_pin")
	
	
func update(delta: float) -> void:
	if not hooked:
		if tips_in and Input.is_action_pressed("left_mouse") and katana.linear_velocity.length() > hook_threshold:
			anchor = katana_tip.global_position
			hooked = true
			katana.lock_rotation = true
			swing_pin.set_node_b(hook_body.get_path())
			swing_pin.bias = 0.9
			swing_pin.global_position = anchor
			get_parent().get_parent().add_child(swing_pin)
			
		elif Input.is_action_pressed("right_mouse"):
			katana.lock_rotation = true
		else:
			katana.lock_rotation = false
	elif Input.is_action_just_released("left_mouse"):
			hooked = false
			swing_pin.node_b = NodePath("")

func physics_update(delta: float):
	katana_movement()
	katana_thrust()
	

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ground"):
		hook_body = body
		tips_in = true
		grabbing.emit()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Ground"):
		hook_body = null
		tips_in = false
		releasing.emit()

func katana_movement()->void:
	var target_pos = katana.get_global_mouse_position()
	var to_target = target_pos - katana.global_position
	var distance = to_target.length()

	if katana.freeze != true:
		if distance > deadzone:
			var direction = to_target.normalized()
			katana.apply_central_force(direction * move_speed)
		else:
			katana.linear_velocity = katana.linear_velocity * 0.8

func katana_thrust():
	var target_pos = katana.get_global_mouse_position()
	var to_target = target_pos - katana.global_position
	var direction = to_target.normalized()
	if Input.is_action_just_pressed("space") and thrust_cooldown == false:
		thrust_cooldown = true
		thrusting_time = true
		await get_tree().create_timer(5).timeout
		reset_thrust_cooldown()
	if thrusting_time:
		thrusting_time = false
		thrusting = true
		await get_tree().create_timer(1.5).timeout
		thrusting = false
	if thrusting:
		katana.apply_central_force(direction * thrust_force)

func reset_thrust_cooldown():
	thrust_cooldown = false
