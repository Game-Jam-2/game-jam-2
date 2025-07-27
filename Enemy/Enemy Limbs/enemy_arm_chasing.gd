extends State

var player_position:Vector2
var raycasts:Array[RayCast2D]
var speed:int = 200
var pull_strength:int = 200
var floor_pos:Vector2
var grabbing:bool = false
var swing_pin: PinJoint2D
var floor:Node2D
var hand_boost:int = 200
func enter(previous_state_path: String,data:={}):
	player_position = data["player_position"]
	raycasts = data["raycasts"]
	get_node("Pull_Timer").start()
	get_node("Pull_Timer").timeout.connect(timeout)
	object_reference.get_parent().get_parent().get_node("Torso").get_node("Attack_Range").body_entered.connect(attack_range_entered)
	
func physics_update(_delta:float):
	for raycast in raycasts:
		if raycast.is_colliding() and raycast.get_collider().name == "Torso":
			player_position = raycast.get_collision_point()
		if raycast.is_colliding() and raycast.get_collider().is_in_group("Ground"):
			floor_pos = raycast.get_collision_point()
			floor = raycast.get_collider()		

	var direction:Vector2 = (player_position - object_reference.global_position)
	var force = direction.x * speed * _delta
	
	object_reference.apply_central_force(Vector2(force,floor_pos.y))
	
	if grabbing:
		grab()
		await get_tree().create_timer(1)
		object_reference.get_parent().get_node("Bicep").apply_impulse(Vector2(force,floor_pos.y))
		object_reference.get_parent().get_node("ForeArm").apply_impulse(Vector2(force,floor_pos.y))
		swing_pin.queue_free()
		grabbing = false

		
	
func grab() -> void:
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(object_reference.get_path())
	swing_pin.set_node_b(floor.get_path())
	swing_pin.bias = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	object_reference.get_parent().add_child(swing_pin)
	
func timeout()->void:
	grabbing = true

func attack_range_entered(body:Node2D):
	print("range_entered")
	var data = {"raycasts": raycasts}	
	finished.emit("Attacking",data)
	
