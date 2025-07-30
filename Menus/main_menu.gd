extends Control
var start_scene := "res://test_stage.tscn"

@onready var new_game = $"VBoxContainer/New Game"
@onready var quit = $VBoxContainer/Quit

func _ready() -> void:
	new_game.connect("button_down", load_game)
	quit.connect("button_down", quit_game)

func load_game():
	get_tree().change_scene_to_file(start_scene)

func quit_game():
	get_tree().quit()
