extends Area2D

@onready var Katana = $".."
@onready var swing_pin = $"../../swing_pin"

signal grabbing

var anchor: Vector2
var hooked = false
var hook_threshold = 10.0
var tips_in = false
var Katana_pos: Vector2
var hook_body: Node

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(delta: float) -> void:
	if not hooked:
		if tips_in and Input.is_action_pressed("left_mouse") and Katana.linear_velocity.length() > hook_threshold:
			anchor = global_position
			hooked = true
			Katana.lock_rotation = true
			swing_pin.set_node_b(hook_body.get_path())
			swing_pin.bias = 0.9
			swing_pin.global_position = anchor
			get_parent().get_parent().add_child(swing_pin)
			
		elif Input.is_action_pressed("right_mouse"):
			Katana.lock_rotation = true
		else:
			Katana.lock_rotation = false
	elif Input.is_action_just_released("left_mouse"):
			hooked = false
			swing_pin.node_b = NodePath("")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ground"):
		hook_body = body
		tips_in = true
		grabbing.emit()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Ground"):
		hook_body = null
		tips_in = false
