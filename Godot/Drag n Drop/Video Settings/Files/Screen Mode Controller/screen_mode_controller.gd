#@tool, @icon, @static_unload
extends PanelContainer

# --= Documentation =--
# Written by: James Krakora
# Function:
# --=================--

# === Variables ===
# --- Signals ---
# --- Enums ---
enum ScreenModes {
	WINDOWED,
	FULLSCREEN,
}
# --- Constants ---
const MODES = [
	"Windowed",
	"Fullscreen",
]
# --- Static ---
# --- @export ---
# --- Regular ---
var preferred := 0
# --- @onready ---

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
func _ready() -> void:
	for mode in MODES:
		$HBoxContainer/OptionButton.add_item(mode)
	set_screen_mode_to_index(preferred)


#func _unhandled_input(event: InputEvent) -> void:
#func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
func set_screen_mode_to_index(index : int) -> void:
	match index:
		ScreenModes.WINDOWED: 
			get_window().mode = Window.MODE_WINDOWED
		ScreenModes.FULLSCREEN: 
			get_window().mode = Window.MODE_FULLSCREEN

# --- Private Funcs ---
# --- Subclasses ---
# End of Script
