extends Node
class_name LimbManager

var limb = preload("res://De Cave/arm_cave_test.tscn")

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Remove Limb in Cave"):
		on_limb_enter_cave("limb")

func _ready() -> void:
	connect("limb_sacrifice", on_limb_sacrificed)

# Called when a new limb enters cave (either armoury, pile or grinder) (currently spawning every time hit tab not just once help)
func on_limb_enter_cave(limb_name: String):
	var limb_scene = limbs["arm_basic"]
	var limb_instance = limb.instantiate()
	limb_instance.position = get_viewport().get_mouse_position()
	add_child(limb_instance)


# Called when a limb is collected
func on_limb_collected(limb_name: String):
	if limb_name in limbs:
		limbs[limb_name]["collected_count"] += 1
		limbs[limb_name]["strength"] *= 1.2  #adjust to change buff


# Called when a limb is sacrificed
func on_limb_sacrificed(limb_name: String):
	print("wahoo")
	if limb_name in limbs:
		var group = limbs[limb_name]["group"]
		groups[group]["sacrificed_count"] += 1
		groups[group]["tension_bonus"] += 0.2  # adjust to change buff
		
		for limb_key in limbs.keys():
			if limbs[limb_key]["group"] == group:
				var base = limbs[limb_key]["base_tension"]
				var bonus = groups[group]["tension_bonus"]
				limbs[limb_key]["tension"] = base * bonus
