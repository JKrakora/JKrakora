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
## May be fucked right now, too lazy to check after some edits
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


## For changing Resolution and Window mode
## Some Resolutions being: 640x360(pixel art), 1920x1080 (Standard), 2560x1080 (Ultrawide)
func change_resolution(resolution: Vector2i) -> void:
	Window.size = resolution
func change_window_mode(mode: Window.Mode) -> void:
	Window.mode = mode


func get_seamless_xz_noise_3d(coordinate: Vector3, world_size: Vector3i, noise: FastNoiseLite) -> float:
	var x_angle = (float(coordinate.x) / float(world_size.x)) * TAU
	var x_cos = cos(x_angle)
	var x_sin = sin(x_angle)
	
	var z_angle = (float(coordinate.z) / float(world_size.z)) * TAU
	var z_cos = cos(z_angle)
	var z_sin = sin(z_angle)
	
	var height_step = float(coordinate.y) * 0.2 ## default: 0.2
	var base_value = noise.get_noise_3d(
		x_cos + z_sin,
		x_sin + height_step,
		z_cos# + height_step ## idek what this was here for originally, but results look better without it soooo
	)
	
	var height_bias:= 0.35 ## default: 0.35
	var height_gradient = float(coordinate.y) / float(world_size.y)
	var final_value = base_value - (height_gradient - height_bias)
	
	return final_value ## > 0.0 as a threshold gives decent enough results
