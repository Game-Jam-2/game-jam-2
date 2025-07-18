extends Control

var isOpen = false

func open() -> void:
	visible = true
	isOpen = true
	get_tree().paused = true

func close() -> void:
	visible = false
	isOpen = false
	get_tree().paused = false

# im unsure about this bit, this isnt in the functioning one on the old game but i don know whats happenninnn
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		print("pause")
		open()

# this pause menu scene and script isnt connected to the main thing so its not working currently if you run the whole thing :thumbs_up:
# will probably need some wiggling to make work once integrated but the buttons work yippeee
