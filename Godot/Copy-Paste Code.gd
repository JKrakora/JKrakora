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


## Creates a Flat-3D array of 'voxel data' which loops on X and Z but not Y.
## Typically done by creating and sampling 5D noise, this works by mapping
## X and Z to a circle while keeping Y linear.
## @param:noise should be setup beforehand.
## @param:size is the effective world size.
## @param:normalize forces the data range to be [-1,1].
## @param:height_step effectively changes how vertically tall features are; 
## Lower makes pillars, too high makes weird floating plate formations.
## @param:height_bias changes where the bulk of the mass is vertically.
func get_seamless_xz_noise_3d(noise: FastNoiseLite, size: Vector3i, normalize:= false, height_step:= 0.2, height_bias:= 0.35) -> PackedFloat32Array:
	var max_value = -INF
	var min_value = INF
	var data: PackedFloat32Array= []
	data.resize(size.x * size.y * size.z)
	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				var x_angle = x * TAU / size.x
				var z_angle = z * TAU / size.z
				var base_value = noise.get_noise_3d(
					cos(x_angle) + sin(z_angle), 
					sin(x_angle) + (y * height_step), 
					cos(z_angle))
				var final_value = base_value - ((float(y) / size.y) - height_bias)
				data[x + (z * size.x) + (y * size.x * size.z)] = final_value
				
				# Best to collect here even to save another pass.
				if final_value > max_value:
					max_value = final_value
				elif final_value < min_value:
					min_value = final_value
	
	# Unlike typical normalization, this makes the range [-1, 1].
	if normalize:
		var normalized_range = max_value - min_value
		for index in range(data.size()):
			data[index] = 2 * ((data[index] - min_value) / normalized_range) - 1
	
	return data
