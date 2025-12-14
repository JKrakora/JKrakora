@abstract
class_name State extends Node

# --= Documentation =--
# Written by: James Krakora
# Function:
# --=================--

signal transition
@export var state_name : StringName
var object

@abstract func enter(object_reference)
@abstract func exit()
@abstract func process(_delta : float)
@abstract func physics_process(_delta : float)

# === End of Script ===
