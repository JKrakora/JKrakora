class_name State
extends Node

var user

func enter() -> void:
	print("%s: Entering %s" % [user.name, name])


func exit() -> void:
	print("%s: Exiting %s" % [user.name, name])


func process_input(event: InputEvent) -> State:
	return null


func process_frame(delta: float) -> State:
	return null


func process_physics(delta: float) -> State:
	return null
