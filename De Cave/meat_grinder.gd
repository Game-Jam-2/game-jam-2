extends CollisionShape2D

var limb = preload("res://De Cave/arm_cave_test.tscn")



func _limb_sacrificed():
	emit_signal("limb_sacrificed")

func _on_meat_grinder_body_entered(body: Node2D) -> void:
	if body == limb:
		_limb_sacrificed()
