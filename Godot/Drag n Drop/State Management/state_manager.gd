class_name StateManager extends Node

# --= Documentation =--
# Written by: James Krakora
# Function:
# --=================--

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
# --- @export ---
@export var initial_state : State
# --- Regular ---
var states := {}
var current_state : State
var current_state_name : StringName
# --- @onready ---
@onready var object_reference := get_parent()

# === Functions ===
#func _init() -> void:
#func _enter_tree() -> void:
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.state_name.to_lower()] = child
			child.transition.connect(_handle_transition)
	
	if initial_state:
		initial_state.enter(object_reference)
		current_state = initial_state
		current_state_name = initial_state.state_name


#func _unhandled_input(event: InputEvent) -> void:
func _process(delta: float) -> void:
	if current_state: current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state: current_state.physics_process(delta)


# --- Public Funcs ---
# --- Private Funcs ---
func _handle_transition(exiting_state : State, entering_state_name : String) -> void:
	if exiting_state != current_state: 
		return
	
	var new_state = states.get(entering_state_name.to_lower())
	if not new_state: 
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter(object_reference)
	current_state = new_state
	current_state_name = entering_state_name


# === End of Script ===
