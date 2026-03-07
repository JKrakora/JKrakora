#@tool, @icon, @static_unload
class_name Teleporter
extends Moveable

# === Doc Comments ===
# Written by: James Krakora
# Function: An Object that can be "thrown" by the Player to travel through the
# level interacting with geometry. Once it becomes "Anchored" on the level, the
# Player can teleport to it. 
# ====================

# === Variables ===
# --- Signals ---
# --- Enums ---
enum States {INACTIVE, TRAVELLING, ANCHORED}
# --- Constants ---
# --- Static ---
# --- @export ---
@export var enabled := true
@export var travelling_form : Node2D
@export var anchored_form : Node2D
@export var destination : Node2D
# --- Regular ---
var current_state : States
var player : Player
var acceleration_vector : Vector2
var acceleration_magnitude : float
# --- @onready ---

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
func _ready() -> void:
	_set_visibilities(false, false)


#func _process(delta: float) -> void:
var collision_info : KinematicCollision2D
func _physics_process(delta: float) -> void:
	if current_state != States.TRAVELLING:
		return
	
	velocity += acceleration_vector * acceleration_magnitude * delta
	collision_info = move_and_collide(velocity * delta)
	if not collision_info:
		return
	
	match collision_info.get_collider().name:
		"Bounce": _handle_bounce_interaction()
		"Slick": _handle_slick_interaction()
		_: _make_anchored()


# --- Public Funcs ---
func act(act_will_break := false) -> void:
	if not enabled:
		return
	
	if act_will_break:
		_make_inactive()
		return
	
	match current_state:
		States.INACTIVE: _make_travelling()
		States.TRAVELLING: pass
		States.ANCHORED: _make_teleport()


func is_active() -> bool:
	return current_state != States.INACTIVE


func set_destination_height(height : float) -> void:
	destination.position.y = -height + travelling_form.shape.radius
	anchored_form.position.y += travelling_form.shape.radius


# --- Private Funcs ---
func _make_travelling() -> void:
	current_state = States.TRAVELLING
	_set_visibilities(true, false)
	position = player.position
	velocity = player.get_normalized_direction_to_mouse() * speed


func _make_anchored() -> void:
	current_state = States.ANCHORED
	_set_visibilities(false, true)
	rotation = get_rotation_from_normal(collision_info.get_normal())


func _make_inactive() -> void:
	current_state = States.INACTIVE
	_set_visibilities(false, false)


func _make_teleport() -> void:
	player.position = destination.global_position


func _handle_bounce_interaction() -> void:
	velocity = velocity.bounce(collision_info.get_normal())


func _handle_slick_interaction() -> void:
	velocity = Vector2.ZERO


func _set_visibilities(is_travelling_visible : bool, is_anchored_visible : bool) -> void:
	travelling_form.visible = is_travelling_visible
	anchored_form.visible = is_anchored_visible


# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
