extends Node
class_name State

signal finished(next_state_path: String,data: Dictionary)
var object_reference:Node
func _ready() -> void:
	object_reference = get_parent()
func handle_input(_event:InputEvent) -> void:
	pass
	
func update(_delta:float) -> void:
	pass

func physics_update(_delta:float) -> void:
	pass

func enter(previous_state_path: String ,data := {}) -> void:
	pass

func exit()->void:
	pass
