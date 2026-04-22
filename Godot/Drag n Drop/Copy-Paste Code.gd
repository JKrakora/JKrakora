## Regular Camera movement and Cursor containment
var camera_sensitivity:= 0.1
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * camera_sensitivity
		$Camera3D.rotation_degrees.x -= event.relative.y * camera_sensitivity
		$Camera3D.rotation_degrees.x = clampf($Camera3D.rotation_degrees.x, -89, 89)


## Camera Movement with Freeable Cursor containment
## Requires "free_cursor" InputEvent
var camera_sensitivity:= 0.1
var is_cursor_being_freed := false
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not is_cursor_bring_freed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event.is_action_pressed("free_cursor"):
		is_cursor_being_freed = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if is_cursor_being_freed and event.is_action_released("free_cursor"):
		is_cursor_being_freed = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * camera_sensitivity
		$Camera3D.rotation_degrees.x -= event.relative.y * camera_sensitivity
		$Camera3D.rotation_degrees.x = clampf($Camera3D.rotation_degrees.x, -89, 89)

