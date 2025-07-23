extends ServoJoint  # Now can extend by class_name

func _ready():
	target_angle = deg_to_rad(90)
