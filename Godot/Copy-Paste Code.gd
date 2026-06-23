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


## Creates 3d voxel data for terrain that loops in the X and Z directions, but 
## not Y. This is typically done by generating 5D noise, but this works by 
## mapping each X and Z value onto a circle and going from there.
## @param:normalize forces the value range to [-1,1], NOT [0,1].
## @param:height_step_mult changes how long features appear vertically, lower mult makes pillars.
## @param:height_bias changes where the bulk of mass is on the y-level, lower bias means lower average.
func get_seamless_xz_noise_3d(noise: FastNoiseLite, normalize:= false, height_step_mult:= 0.2, height_bias:= 0.35) -> PackedFloat32Array:
	var data: PackedFloat32Array= []
	data.resize(WORLD_DIMENSIONS.x * WORLD_DIMENSIONS.y * WORLD_DIMENSIONS.z)
	for x in range(WORLD_DIMENSIONS.x):
		for y in range(WORLD_DIMENSIONS.y):
			for z in range(WORLD_DIMENSIONS.z):
				var x_angle = x * TAU / WORLD_DIMENSIONS.x
				var x_cos = cos(x_angle)
				var x_sin = sin(x_angle)
				var z_angle = z * TAU / WORLD_DIMENSIONS.z
				var z_cos = cos(z_angle)
				var z_sin = sin(z_angle)
				var height_step = y * height_step_mult
				var base_value = noise.get_noise_3d(
					x_cos + z_sin,
					x_sin + height_step,
					z_cos# + height_step ## idek what this was here for originally, but results look better without it
				)
				var height_gradient = float(y) / WORLD_DIMENSIONS.y
				var final_value = base_value - (height_gradient - height_bias)
				data[get_index_from_coord(x,y,z)] = final_value
	
	if normalize:
		var max_val = -INF
		var min_val = INF
		for value in data:
			if value > max_val:
				max_val = value
			elif value < min_val:
				min_val = value
		
		var normalized_range = max_val - min_val
		for index in range(data.size()):
			data[index] = 2 * ((data[index] - min_val) / normalized_range) - 1
	
	return data
