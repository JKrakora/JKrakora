#@tool, @icon, @static_unload
class_name SeekingCamera
extends Camera2D

# === Doc Comments ===
# Written by: James Krakora
# Function: A Camera that allows the Player to target an active Ring or Card,
# making the Camera travel to and follow it. By default it targets the Player.
# It can also zoom in and out with the scroll wheel (by default)
# ====================

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
const MIN_ZOOM := 0.5
const MAX_ZOOM := 2.0
const DEFAULT_ZOOM := 1.0
const ZOOM_STEP := .05
# --- Static ---
# --- @export ---
# --- Regular ---
# --- @onready ---

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
#func _ready() -> void:
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("zoom in"):
		zoom += Vector2(ZOOM_STEP, ZOOM_STEP)
	elif Input.is_action_just_pressed("zoom out"):
		zoom -= Vector2(ZOOM_STEP, ZOOM_STEP)
	elif Input.is_action_just_pressed("reset zoom"):
		zoom = Vector2(DEFAULT_ZOOM, DEFAULT_ZOOM)
	
	zoom = zoom.clampf(MIN_ZOOM, MAX_ZOOM)


#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
func set_goal(goal : Moveable) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", goal.position, 0.4)
	rotation = goal.get_specific_rotation()


# --- Private Funcs ---
# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
