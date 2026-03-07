#@tool, @icon, @static_unload
class_name Moveable
extends CharacterBody2D

# === Doc Comments ===
# Written by: James Krakora
# Function: Base class for the Player and Teleporters giving them 
# CharacterBody2D funtionality while storing common variables and functions that
# can be overwritten.
# ====================

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
# --- Static ---
# --- @export ---
# --- Regular ---
var gravity := 500.0
var speed := 200.0
# --- @onready ---

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
#func _ready() -> void:
#func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
func get_rotation_from_normal(normal := up_direction) -> float:
	return normal.angle() + (PI / 2.0)


func get_specific_rotation() -> float:
	return rotation


# --- Private Funcs ---
# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
