extends Node
class_name LimbManager

@onready var meat_grinder = $"Meat Grinder"

var limb: Node

var groups := {
	"human": {
		"sacrificed_count": 0,
		"tension_bonus": 1.0
	},
	"entity": {
		"sacrificed_count": 0,
		"tension_bonus": 1.0
	},
	"effect": {
		"sacrificed_count": 0,
		"tension_bonus": 1.0
	},
	"weapon": {
		"sacrificed_count": 0,
		"tension_bonus": 1.0
	}
}

var limbs := {
	"arm_basic": {
		"strength": 5.0,
		"base_tension": 8.0,
		"tension": 8.0,
		"group": "human",
		"collected_count": 0
	},
	"leg_basic": {
		"strength": 7.0,
		"base_tension": 10.0,
		"tension": 10.0,
		"group": "human",
		"collected_count": 0
	}
}

func _ready() -> void:
	meat_grinder.connect("body_entered", on_limb_sacrificed)


# Called when a limb is collected
func on_limb_collected(limb_name: String):
	if limb_name in limbs:
		limbs[limb_name]["collected_count"] += 1
		limbs[limb_name]["strength"] *= 1.2  #adjust to change buff


# Called when a limb is sacrificed
func on_limb_sacrificed(body: Node):
	if body.get_parent():
		if body.get_parent().is_in_group("Limbs"):
			limb = body.get_parent()
			var limb_name = body.name
			if limb_name in limbs:
				var group = limbs[limb_name]["group"]
				groups[group]["sacrificed_count"] += 1
				groups[group]["tension_bonus"] += 0.2  # adjust to change buff
				
				for limb_key in limbs.keys():
					if limbs[limb_key]["group"] == group:
						var base = limbs[limb_key]["base_tension"]
						var bonus = groups[group]["tension_bonus"]
						limbs[limb_key]["tension"] = base * bonus
			limb.queue_free()
