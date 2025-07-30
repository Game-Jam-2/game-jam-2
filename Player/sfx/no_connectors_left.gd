extends AudioStreamPlayer2D
@onready var player = get_parent().get_parent()

func _process(delta: float) -> void:
	var connector_count = 0
	for child in player.get_children():
		if "Connector " in child.name:
			connector_count += 1
	if connector_count == 0:
		play()
