@abstract
class_name State 
extends Node

# --= Documentation =--
# Written by: James Krakora
# Function: 
# --=================--

signal transition(exiting_state : State, entering_state_name : String)
@export var state_name : String
var state_user : Node

func _ready(): _set_processes(false)

@abstract func enter(user)
@abstract func exit()

func _set_processes(enabled : bool) -> void:
	set_process(enabled)
	set_physics_process(enabled)
