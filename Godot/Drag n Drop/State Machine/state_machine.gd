class_name StateMachine
extends Node

@export var start_state: State
var current_state : State

func init(user: Node) -> void:
	for state in get_children():
		state.user = user
	change_state(current_state)


func change_state(new_state: State) -> void:
	if not new_state:
		return
	
	if current_state == new_state:
		return
	
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()


func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)


func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)
