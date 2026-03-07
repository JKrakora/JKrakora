#@tool, @icon, @static_unload
class_name Player
extends Moveable

# === Doc Comments ===
# Written by: James Krakora
# Function: Allows basic movement (including jumping with coyote time), the use 
# of 2 Teleporters, and basic control of a Seeking Camera
# ====================

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
const JUMP_IMPULSE := 200.0
const COYOTE_TIME_SECONDS := 0.2
# --- Static ---
# --- @export ---
@export var ring : Ring
@export var card : Card
@export var seeker : SeekingCamera
# --- Regular ---
var ring_peek_count : int
var card_peek_count : int
var coyote_time_remaining_seconds : float
# --- @onready ---

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
func _ready() -> void:
	speed = 150.0
	ring.player = self
	ring.set_destination_height(get_height() / 2.0)
	card.player = self
	card.set_destination_height(get_height() / 2.0)


var action_breaks := false
func _process(_delta: float) -> void:
	# -- Teleporter Actions --
	action_breaks = Input.is_action_pressed("break")
	if Input.is_action_just_pressed("ring action"):
		ring.act(action_breaks)
	if Input.is_action_just_pressed("card action"):
		card.act(action_breaks)
	
	# -- Peeking/Seeking --
	ring_peek_count = ring_peek_count + 1 if Input.is_action_pressed("peek ring") else 0
	card_peek_count = card_peek_count + 1 if Input.is_action_pressed("peek card") else 0
	
	# If neither are pressed, follow Player
	# If both are pressed, follow the one pressed more recently (smaller count)
	# If only one is pressed, follow it (larger count)
	if ring_peek_count == 0 and card_peek_count == 0:
		seeker.set_goal(self)
	elif ring_peek_count > 0 and card_peek_count > 0:
		seek_teleporter(ring if ring_peek_count < card_peek_count else card)
	else:
		seek_teleporter(ring if ring_peek_count > card_peek_count else card)


func _physics_process(delta: float) -> void:
	var relative_velocity := velocity.rotated(-get_rotation_from_normal())
	relative_velocity.x = Input.get_axis("move left", "move right") * speed
	
	if not is_on_floor():
		relative_velocity.y += gravity * delta
		coyote_time_remaining_seconds -= delta
	else:
		relative_velocity.y = 0
		coyote_time_remaining_seconds = COYOTE_TIME_SECONDS
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time_remaining_seconds > 0):
		relative_velocity.y = -JUMP_IMPULSE
	
	velocity = relative_velocity.rotated(get_rotation_from_normal())
	move_and_slide()


# --- Public Funcs ---
func get_height() -> float:
	if $Collision.shape is RectangleShape2D:
		return $Collision.shape.size.y
	return 0


func get_normalized_direction_to_mouse() -> Vector2:
	return (get_global_mouse_position() - self.position).normalized()


func seek_teleporter(teleporter : Teleporter) -> void:
	seeker.set_goal(teleporter if teleporter.is_active() else self)


# --- Private Funcs ---
# --- Subclasses ---
# End of Script, 'cept for the trailing line :(
