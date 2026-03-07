#@tool, @icon, @static_unload
class_name Ring
extends Teleporter

# === Doc Comments ===
# Written by: James Krakora
# Function: A Teleporter that travels with some speed and it affected by 
# gravity. On teleport, it just changes the players position while keeping their
# local gravity.
# ====================

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
# --- Static ---
# --- @export ---
# --- Regular ---
# --- @onready ---

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
func _ready() -> void:
	speed = 500
	acceleration_vector = Vector2.DOWN
	acceleration_magnitude = gravity
	super()


#func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
func get_specific_rotation() -> float:
	return player.get_rotation_from_normal()


# --- Private Funcs ---
func _handle_slick_interaction() -> void:
	## BUG: When stuck on a Slick surface, if the Player uses the Card to 
	## change gravity, the Ring will change its acceleration_vector since it's 
	## still "colliding" with a Slick. This single line is the cause, as it's
	## called continuously while technically "Travelling" on the Slick. 
	acceleration_vector = -player.up_direction
	super()


# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
