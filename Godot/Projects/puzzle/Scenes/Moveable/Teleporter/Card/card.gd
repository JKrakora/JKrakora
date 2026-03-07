#@tool, @icon, @static_unload
class_name Card
extends Teleporter

# === Doc Comments ===
# Written by: James Krakora
# Function: A Teleporter that travels quickly and is unaffected by gravity
# which, on teleport, changes the Players gravity and resets their velocity.
# Essentially makes the anchored surface the new "Floor".
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
	speed = 800
	acceleration_magnitude = 0
	acceleration_vector = Vector2.DOWN
	super()


#func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
func _make_inactive() -> void:
	super()
	acceleration_magnitude = 0


func _make_teleport() -> void:
	player.up_direction = collision_info.get_normal()
	player.rotation = get_rotation_from_normal(player.up_direction)
	player.velocity = Vector2.ZERO # NOTE: Could be useful, maybe. 
	super()


func _handle_slick_interaction() -> void:
	acceleration_magnitude = gravity
	super()


# --- Private Funcs ---
func _make_travelling() -> void:
	rotation = player.rotation
	super()


# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
