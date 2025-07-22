extends Area2D

@onready var Katana = $".."

var anchor: Vector2
var hooked = false
var hook_threshold = 10.0
var tips_in = false
var Katana_pos: Vector2

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	if not hooked:
		if tips_in and Input.is_action_pressed("left_mouse") and Katana.linear_velocity.length() > hook_threshold:
			anchor = global_position
			hooked = true
			Katana.lock_rotation = true
			Katana_pos = Katana.global_position
		elif Input.is_action_pressed("right_mouse"):
			Katana.lock_rotation = true
		else:
			Katana.lock_rotation = false
	else:
		if Input.is_action_just_released("left_mouse"):
			hooked = false

func _physics_process(delta: float) -> void:
	if hooked:
		global_position = anchor
		Katana.global_position = Katana_pos
func _on_body_entered(body: Node) -> void:
	tips_in = true

func _on_body_exited(body: Node) -> void:
	tips_in = false
