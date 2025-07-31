class_name StateMachine extends Node

@export var initial_state:State = null
@export var initial_equipped_state:State = null

@onready var current_state:State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
	).call()
var first:bool = true

func _ready() -> void:
	for state_node:State in get_children():
		state_node.finished.connect(_transistion_to_next_state)
		
	await  owner.ready
	current_state.enter("")
		
func _transistion_to_next_state(target_state_path: String ,data:Dictionary = {}) -> void:
	var previous_state_path := current_state.name
	current_state.exit()
	current_state = get_node(target_state_path)
	current_state.enter(previous_state_path,data)
	
func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _process(delta: float) -> void:
	current_state.update(delta)
	if current_state.name == "Equipping":
		var transition_to = initial_equipped_state.name
		_transistion_to_next_state(transition_to, {})


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)
