class_name SmoothCamera3D
extends Camera3D

@export var target: Node3D

func _ready() -> void:
	top_level = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

var camera_sensitivity:= 0.1
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * camera_sensitivity
		rotation_degrees.x -= event.relative.y * camera_sensitivity
		rotation_degrees.x = clampf(rotation_degrees.x, -89, 89)


func _process(_delta: float) -> void:
	global_position = target.get_global_transform_interpolated().origin
