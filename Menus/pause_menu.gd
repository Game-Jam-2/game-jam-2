extends Control
@onready var resume = $VBoxContainer/Resume
@onready var quit = $VBoxContainer/Quit

var isOpen = false

func _ready() -> void:
	resume.connect("button_down", unpause)
	quit.connect("button_down", quit_game)

func pause() -> void:
	visible = true
	isOpen = true
	get_tree().paused = true

func unpause() -> void:
	visible = false
	isOpen = false
	get_tree().paused = false

func quit_game():
	get_tree().quit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		if isOpen:
			unpause()
		else:
			pause()
