extends Node
@export var limb: String

func _ready() -> void:
	spawn_limb()

func spawn_limb():
	var limb_scene = load("res://Player/Limbs/" + limb + "/" + limb + ".tscn")
	print(limb_scene)
	var limb_instance = limb_scene.instantiate()
	add_child(limb_instance)
	
