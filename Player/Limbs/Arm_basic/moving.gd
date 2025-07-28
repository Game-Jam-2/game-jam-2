extends State
var speed : int = 1000
var collision_in_progress = false
var object_collided : Node2D
var first_entry:bool = true #represents the first time this state is entered used to ensure that 
#connections made when the state is first entered are not made twice 
var hand_boost : int = 500
var deadzone : int = 40
var hand:RigidBody2D

func enter(previous_state_path: String,data:= {}) -> void:
	hand = object_reference.get_parent().get_node("Hand")
	if first_entry:
		hand.contact_monitor = true
		hand.max_contacts_reported = 10
		hand.body_shape_entered.connect(on_collision)
		hand.body_shape_exited.connect(on_collision_end)
		await get_tree().create_timer(2)
		first_entry = false
	
	
	

func physics_update(delta: float) -> void:
	var mouse_position = hand.get_global_mouse_position()
	var direction:Vector2 = (mouse_position - hand.global_position).normalized()
	var distance = (mouse_position - hand.global_position).length()
	var force = direction * speed * delta 
	if distance > deadzone:
		hand.apply_central_force(force * hand_boost)
	else:
		hand.linear_velocity = object_reference.linear_velocity * 0.8





func handle_input(event: InputEvent) -> void:
	if (event.is_action_pressed("right_mouse") and collision_in_progress):
		#sending object collided with to next state
		var data:Dictionary = {"object_collided" : object_collided}
		finished.emit("Grabbing",data)


func on_collision(body_rid:RID,body:Node,body_shape_index: int, local_shape_index:int) -> void:
	collision_in_progress = true
	object_collided = body

func on_collision_end(body_rid:RID,body:Node,body_shape_index: int, local_shape_index:int) -> void:
	collision_in_progress = false
