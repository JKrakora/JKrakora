#@tool, @icon, @static_unload
extends PanelContainer

# --= Documentation =--
# Written by: James Krakora
# Function:
# --=================--

# === Variables ===
# --- Signals ---
# --- Enums ---
# --- Constants ---
# --- Static ---
# --- @export ---
@export var resolution_json : JSON
# --- Regular ---
# --- @onready ---
@onready var resolution_data := ResourceManager.get_JSON_as_dict(resolution_json)

# === Functions ===
#func _static_init() -> void:
# --- Remaining Statics ---
#func _init() -> void:
#func _enter_tree() -> void:
func _ready() -> void:
	for res in resolution_data.Resolutions:
		$HBoxContainer/OptionButton.add_item("%dx%d" % res)
	set_resolution_to_index(resolution_data.Preferred)


#func _unhandled_input(event: InputEvent) -> void:
#func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:
# --- Public Funcs ---
func set_resolution_to_index(index : int) -> void:
	if index < 0 or index >= $HBoxContainer/OptionButton.item_count:
		return
	
	var dimensions = _get_size_as_vector2(resolution_data.Resolutions[index])
	get_window().size = dimensions
	get_window().content_scale_size = dimensions
	get_window().mode = get_window().mode


# --- Private Funcs ---
func _get_size_as_vector2(arr : Array) -> Vector2:
	return Vector2(arr[0], arr[1])


# --- Subclasses ---
# End of Script
