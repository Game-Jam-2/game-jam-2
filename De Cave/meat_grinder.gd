extends Area2D

var limb = preload("res://De Cave/arm_cave_test.tscn")
signal limb_sacrifice

func _limb_sacrificed():
	emit_signal("limb_sacrificed")


func _on_meat_grinder_area_entered(body: Node2D) -> void:
	if body == limb:
		_limb_sacrificed()
		print("print")
