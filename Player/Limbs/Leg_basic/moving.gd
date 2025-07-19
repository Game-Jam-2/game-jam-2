extends State
var speed : int = 500
var collision_in_progress = false
var object_collided : Node2D
func enter(previous_state_path: String,data:= {}) -> void:
	object_reference.contact_monitor = true
	object_reference.max_contacts_reported = 10
	object_reference.body_shape_entered.connect(on_collision)
	object_reference.body_shape_exited.connect(on_collision_end)
	

func physics_update(delta: float) -> void:
	var mouse_position = object_reference.get_global_mouse_position()
	var direction:Vector2 = (mouse_position - object_reference.global_position).normalized()
	var distance = (mouse_position -object_reference.global_position).length()
	var force = direction * distance * speed * delta
	object_reference.apply_central_force(force)

func handle_input(event: InputEvent) -> void:
	if (event.is_action_pressed("Grab") and collision_in_progress):
		print("STATE CHANGE")
		assert(object_collided != null)
		#sending object collided with to next state
		var data:Dictionary = {"object_collided" : object_collided}
		finished.emit("Grabbing",data)


func on_collision(body_rid:RID,body:Node,body_shape_index: int, local_shape_index:int) -> void:
	collision_in_progress = true
	object_collided = body

func on_collision_end(body_rid:RID,body:Node,body_shape_index: int, local_shape_index:int) -> void:
	collision_in_progress = false
