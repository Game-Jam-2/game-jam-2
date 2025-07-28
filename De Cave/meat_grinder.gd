extends Area2D

var limb = preload("res://De Cave/arm_cave_test.tscn")
signal limb_sacrifice

func limb_sacrificed():
	limb_sacrifice.emit()
