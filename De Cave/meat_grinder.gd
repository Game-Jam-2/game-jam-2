extends Area2D

var limb = preload("res://De Cave/arm_cave_test.tscn")
signal limb_sacrifice

func _ready() -> void:
	connect("body_entered", _on_meat_grinder_area_entered)


func _on_meat_grinder_area_entered(body) -> void:
	limb = body.get_parent()
	if limb.is_in_group("Limbs"):
		limb_sacrifice.emit(limb.name)
