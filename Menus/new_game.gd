extends Button
var start_scene := "res://testing/test_stage.tscn"

func _ready() -> void:
	connect("button_down", load_game)

func load_game():
	get_tree().change_scene_to_file(start_scene)
