extends RigidBody2D

@onready var Katana = $"../Katana"
@onready var tip_detector = $"../Katana Tip Detector"

var anchor: Vector2
var hooked = false
var hook_threshold = 10.0
var tips_in = false
var Katana_pos: Vector2

func _ready():
	tip_detector.connect("body_entered", _on_body_entered)
	tip_detector.connect("body_exited", _on_body_exited)

func _process(delta: float) -> void:
	if not hooked:
		if tips_in and Input.is_action_pressed("left_mouse") and Katana.linear_velocity.length() > hook_threshold:
			anchor = global_position
			hooked = true
			Katana.lock_rotation = true
			Katana_pos = Katana.global_position
			freeze = true
			
		elif Input.is_action_pressed("right_mouse"):
			Katana.lock_rotation = true
		else:
			Katana.lock_rotation = false
	elif Input.is_action_just_released("left_mouse"):
			hooked = false
			freeze = false
	

func _physics_process(delta: float) -> void:
	if hooked:
		print("hooked")
		global_position = anchor
		Katana.global_position = Katana_pos

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ground"):
		tips_in = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Ground"):
		tips_in = false
