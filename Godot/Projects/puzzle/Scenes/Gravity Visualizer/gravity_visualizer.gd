#@tool, @icon, @static_unload
class_name GravityVisualizer
extends Sprite2D

# === Doc Comments ===
# Written by: James Krakora
# Function: Using the Sprite of an arrow, indicate the direction a Teleporter
# will fall while or once affected by gravity. 
# ====================

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
# --- Static ---
# --- @export ---
@export var reference : Moveable
# --- Regular ---
# --- @onready ---
@onready var camera := get_parent()

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
#func _ready() -> void:
func _process(delta: float) -> void:
	rotation = lerp_angle(rotation, -camera.rotation + _get_counter_rotation(), 5 * delta)


#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
# --- Private Funcs ---
func _get_counter_rotation() -> float:
	if reference and reference is Ring:
		return reference.acceleration_vector.angle() - PI/2
	return 0


# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
