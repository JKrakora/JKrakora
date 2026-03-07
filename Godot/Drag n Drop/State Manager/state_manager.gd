class_name StateManager
extends Node

# --= Documentation =--
# Written by: James Krakora
# Function:
# --=================--

@export var initial_state : State
var states := {}
var current_state : State
var current_state_name : String
@onready var state_user := get_parent()

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.state_name.to_lower()] = child
			child.transition.connect(_handle_transition)
	
	if initial_state:
		initial_state.enter(state_user)
		current_state = initial_state
		current_state_name = initial_state.state_name


func _handle_transition(exiting_state : State, entering_state_name : String):
	if exiting_state != current_state: 
		return
	
	var entering_state = states.get(entering_state_name.to_lower())
	if not entering_state: 
		return
	
	if current_state:
		current_state.exit()
	
	entering_state.enter(state_user)
	current_state = entering_state
	current_state_name = entering_state_name
