extends Control
var limb: Node
var limb_idle: bool = false
@onready var LimbDetector: Node = get_parent().get_node("Torso").get_node("LimbDetector")

func _ready() -> void:
	LimbDetector.connect("body_entered", _on_limb_equipped)
	
func _on_limb_equipped(body: Node) -> void:
	limb = body.get_parent()
	if limb.is_in_group("Limbs"):
		var state = limb.get_node("StateMachine").current_state
		var idle_state = limb.get_node("StateMachine").get_node(limb.name + "_Idle")
		print("state:", state)
		print("idle state", idle_state)
		if state == idle_state:
			visible = true
