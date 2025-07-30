extends Node
class_name LimbManager

@onready var meat_grinder = $"Meat Grinder"
@onready var collection_area = $"Collection Area"

signal send_data

var limb: Node

var groups := {
	"human": {
		"sacrificed_count": 0,
		"tension_bonus": 1.2
	},
	"entity": {
		"sacrificed_count": 0,
		"tension_bonus": 1.2
	},
	"effect": {
		"sacrificed_count": 0,
		"tension_bonus": 1.2
	},
	"weapon": {
		"sacrificed_count": 0,
		"tension_bonus": 1.2
	}
}

var limbs := {
	"arm_basic": {
		"base_strength": 1.0,
		"strength_bonus": 1.1,
		"strength": 1.0,
		"base_tension": 1.0,
		"tension": 1.0,
		"group": "human",
		"collected_count": 0
	},
	"arm_katana": {
		"base_strength": 1.0,
		"strength_bonus": 1.1,
		"strength": 1.0,
		"base_tension": 1.0,
		"tension": 1.0,
		"group": "human",
		"collected_count": 0
	},
	"leg_basic": {
		"base_strength": 1.0,
		"strength_bonus": 1.1,
		"strength": 1.0,
		"base_tension": 1.0,
		"tension": 1.0,
		"group": "human",
		"collected_count": 0
	}
}

func _ready() -> void:
	meat_grinder.connect("body_entered", on_limb_sacrificed)
	collection_area.connect("body_entered", on_limb_collected)
	collection_area.connect("body_exited", on_limb_uncollected)



func on_limb_collected(limb_name: String):
	if limb_name in limbs:
		limbs[limb_name]["collected_count"] += 1
		limbs[limb_name]["strength_bonus"] += 0.1
		
		var base = limbs[limb_name]["base_strength"]
		var bonus = limbs[limb_name]["strength_bonus"]

		limbs[limb_name]["strength"] = base * bonus


func on_limb_uncollected(limb_name: String):
	if limb_name in limbs:
		limbs[limb_name]["collected_count"] -= 1
		limbs[limb_name]["strength_bonus"] -= 0.1
		
		var base = limbs[limb_name]["base_strength"]
		var bonus = limbs[limb_name]["strength_bonus"]

		limbs[limb_name]["strength"] = base * bonus


# Called when a limb is sacrificed
func on_limb_sacrificed(body: Node):
	if body.get_parent():
		if body.get_parent().is_in_group("Limbs"):
			limb = body.get_parent()
			var limb_name = body.name
			var state = limb.get_node("StateMachine").current_state
			var idle_state = limb.get_node("StateMachine").get_node(limb.name + "_Idle")
			if state == idle_state:
				if limb_name in limbs:
					var group = limbs[limb_name]["group"]
					groups[group]["sacrificed_count"] += 1
					groups[group]["tension_bonus"] += 0.2
				
					for limb_key in limbs.keys():
						if limbs[limb_key]["group"] == group:
							var base = limbs[limb_key]["base_tension"]
							var bonus = groups[group]["tension_bonus"]
							limbs[limb_key]["tension"] = base * bonus
					
					limbs[limb_name]["collected_count"] -= 1
					limbs[limb_name]["strength_bonus"] -= 0.1
			
					var base = limbs[limb_name]["base_strength"]
					var bonus = limbs[limb_name]["strength_bonus"]

					limbs[limb_name]["strength"] = base * bonus
				limb.queue_free()

func _physics_process(delta: float) -> void:
	send_data.emit(limbs, groups)
