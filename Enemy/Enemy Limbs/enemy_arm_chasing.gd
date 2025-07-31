extends State

var player_position:Vector2
var raycasts:Array[RayCast2D]
var speed:int = 2
var pull_strength:int = 2
var floor_pos:Vector2
var grabbing:bool = false 
var swing_pin: PinJoint2D
var floor:Node2D

var first_entry:bool = true
var hand:RigidBody2D
func enter(previous_state_path: String,data:={}):
	hand = object_reference.get_parent().get_node("Hand")
	if first_entry:
		player_position = data["player_position"]
		raycasts = data["raycasts"]
		get_node("Pull_Timer").start()
		get_node("Pull_Timer").timeout.connect(timeout)
		object_reference.get_parent().get_parent().get_parent().get_node("Torso").get_node("Attack_Range").body_entered.connect(attack_range_entered)
		first_entry = false
		
func physics_update(_delta:float):
	for raycast in raycasts:
		if raycast.is_colliding() and raycast.get_collider().name == "Torso":
			player_position = raycast.get_collision_point()
		if raycast.is_colliding() and raycast.get_collider().is_in_group("Ground"):
			floor_pos = raycast.get_collision_point()
			floor = raycast.get_collider()		

	var direction:Vector2 = (player_position - hand.global_position)
	var forceX = direction.x * speed * _delta
	var force = direction * speed * _delta
	hand.apply_central_force(Vector2(forceX,floor_pos.y + 50))
	
	if grabbing:
		grab()
		await get_tree().create_timer(1)
		var Torso = object_reference.get_parent().get_parent().get_parent().get_node("Torso")
		var bicep = object_reference.get_parent().get_node("Bicep")
		var foreArm = object_reference.get_parent().get_node("ForeArm")
		
		assert(Torso.name == "Torso")
		assert(bicep.name == "Bicep")
		assert(foreArm.name == "ForeArm")
		
	
		Torso.apply_impulse(force * 5)
		
		swing_pin.queue_free()
		grabbing = false

		
#grabs onto the floor 
func grab() -> void:
	swing_pin = PinJoint2D.new()
	swing_pin.set_node_a(hand.get_path())
	swing_pin.set_node_b(floor.get_path())
	swing_pin.bias = 0.0
	swing_pin.global_position = object_reference.get_parent().get_node("Grab Point").position
	swing_pin.disable_collision = false
	hand.get_parent().add_child(swing_pin)
	
func timeout()->void:
	grabbing = true

func attack_range_entered(body:Node2D):
	print("range_entered")
	var data = {"raycasts": raycasts,"player_torso":body}
	finished.emit("Attacking",data)
	
