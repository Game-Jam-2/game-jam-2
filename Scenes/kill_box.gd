extends Area2D

var death_sound
func _ready() -> void:
	death_sound = get_parent().get_node("SFX").get_node("DeathSound")
	body_entered.connect(body_enter)
	
	
func body_enter(body:Node2D):
	body.queue_free()
	death_sound.play()
	
