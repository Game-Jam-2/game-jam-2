extends AudioStreamPlayer2D

func play_sound(path: String):
	var player = AudioStreamPlayer.new()
	var stream = load(path)
	
	if stream == null:
		print("Failed to load sound:", path)
		return

	player.stream = stream
	player.connect("finished", queue_free) # Clean up after playing
	get_tree().get_root().add_child(player)
	player.play()
