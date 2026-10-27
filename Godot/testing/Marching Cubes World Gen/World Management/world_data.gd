class_name WorldData
extends Resource

## TODO: translate to C# or C++/cpp
## Notes about that:
## C# requires the .NET version of Godot, which Steam doesn't have. I prefer Steam for sync across PC and Laptop.
## C++ is harder (but faster), requiring plugins and file dropping which I don't wanna fuck up.
##
## WorldData.get_mc_chunk_data() is a (if not /THE/) bottleneck

const REGION_SIZE: int = 64
const REGION_HEIGHT: int = 128
@export var _region_count: int
@export var _regions: Array[Array]
@export var _seed: int= 0
@export var _torus_radii: float= 50.0
var world_size: Vector3i: ## problem, gets called too many times
	get:
		return Vector3i(
			_region_count * REGION_SIZE,
			REGION_HEIGHT,
			_region_count * REGION_SIZE
		)

func get_voxel_scalar(global_coord: Vector3i) -> float:
	if global_coord.y >= REGION_HEIGHT:
		return -1.0
	elif global_coord.y < 0:
		return 0.0
	
	var coord = Vector3i(
		posmod(global_coord.x, world_size.x),
		global_coord.y,
		posmod(global_coord.z, world_size.z),
	)
	
	@warning_ignore("integer_division")
	var region_coord = Vector2i(coord.x, coord.z) / REGION_SIZE
	var local_coord = Vector2i(coord.x, coord.z) % REGION_SIZE
	var index = (local_coord.x * REGION_HEIGHT * REGION_SIZE) + (global_coord.y * REGION_SIZE) + (local_coord.y)
	return _regions[region_coord.x][region_coord.y].scalars[index]


func get_chunk_volume(chunk_size: int) -> int:
	return ((chunk_size + 1) ** 2) * (REGION_HEIGHT + 1)


func get_mc_chunk_data(chunk_origin: Vector2i, chunk_size: int) -> PackedFloat32Array:
	var index = 0
	var data:= PackedFloat32Array()
	data.resize(get_chunk_volume(chunk_size))
	for x in range(chunk_size + 1):
		for y in range(REGION_HEIGHT + 1):
			for z in range(chunk_size + 1):
				var voxel_coord = Vector3(
					chunk_origin.x + x, 
					y, 
					chunk_origin.y + z
				)
				data[index] = get_voxel_scalar(voxel_coord)
				index += 1
	return data



func generate_world(region_count: int, torus_radii := 50.0, world_seed := 0) -> void:
	_region_count = region_count
	_seed = world_seed
	_torus_radii = torus_radii
	
	var base_noise = Noise4D.new()
	base_noise.seed = _seed
	base_noise.frequency = 0.01
	
	var overhang_noise = Noise4D.new()
	overhang_noise.seed = _seed + 1
	overhang_noise.frequency = 0.01
	
	var river_noise = Noise4D.new()
	river_noise.seed = _seed + 2
	river_noise.frequency = 0.1
	var river_threshold = 0.98
	var river_depth = 2.0
	var river_wall_shape = 0.3
	
	var ravine_noise = Noise4D.new()
	ravine_noise.seed = _seed + 3
	ravine_noise.frequency = 0.01
	
	var canyon_noise = Noise4D.new()
	canyon_noise.seed = _seed + 4
	canyon_noise.frequency = 0.01
	
	var ridge_noise = Noise4D.new()
	ridge_noise.seed = _seed + 5
	ridge_noise.frequency = 0.01
	
	var plateau_noise = Noise4D.new()
	plateau_noise.seed = _seed + 6
	plateau_noise.frequency = 0.01
	
	var worm_noise = Noise4D.new()
	worm_noise.seed = _seed + 7
	worm_noise.frequency = 0.01
	
	var cheese_noise = Noise4D.new()
	cheese_noise.seed = _seed + 8
	cheese_noise.frequency = 0.01
	
	var floating_noise = Noise4D.new()
	floating_noise.seed = _seed + 9
	floating_noise.frequency = 0.01
	
	var final_value = -1.0
	
	var DEBUG_MIN = INF
	var DEBUG_MAX = -INF
	
	## Region
	_regions.resize(_region_count)
	for rx in range(_region_count):
		_regions[rx].resize(_region_count)
		for rz in range(_region_count):
			var region = RegionData.new()
			_regions[rx][rz] = region
			
			var data = PackedFloat32Array()
			data.resize(REGION_SIZE * REGION_HEIGHT * REGION_SIZE)
			
			## Local
			var index = 0
			for lx in range(REGION_SIZE):
				for ly in range(REGION_HEIGHT):
					for lz in range(REGION_SIZE):
						var global_coord = Vector3i(
							rx * REGION_SIZE + lx,
							ly, 
							rz * REGION_SIZE + lz
						)
						
						var theta_x = TAU * global_coord.x / float(world_size.x)
						var y_component = float(global_coord.y) / world_size.y
						var theta_z = TAU * global_coord.z / float(world_size.z)
						var torus_coord = Vector4(
							cos(theta_x), 
							sin(theta_x), 
							cos(theta_z), 
							sin(theta_z)
						) * (world_size.x / _torus_radii)
						
						var base_sample = base_noise.get_noise_4dv(torus_coord)
						var base_height = ((base_sample + 1.0) * 0.5)
						final_value = base_height - y_component
						
						var river_sample = river_noise.get_noise_4dv(torus_coord)
						var river_ridge = pow(1.0 - absf(river_sample), river_wall_shape)
						if river_ridge > river_threshold and y_component > base_height - 0.1 and y_component < base_height + 0.1:
							final_value -= (river_ridge - river_threshold) * river_depth * (1.0 - y_component)
							final_value = clampf(final_value, -1.0, 1.0)
						
						#var ravine_sample = ravine_noise.get_noise_4dv(torus_coord)
						#var canyon_sample = canyon_noise.get_noise_4dv(torus_coord)
						
						#var ridge_sample = ridge_noise.get_noise_4dv(torus_coord)
						#var plateau_sample = plateau_noise.get_noise_4dv(torus_coord)
						#var worm_sample = worm_noise.get_noise_4dv(torus_coord)
						#var cheese_sample = cheese_noise.get_noise_4dv(torus_coord)
						#var overhang_sample = overhang_noise.get_noise_4dv(torus_coord)
						#var floating_sample = floating_noise.get_noise_4dv(torus_coord)
						
						if (1.0 - y_component) > DEBUG_MAX:
							DEBUG_MAX = (1.0 - y_component)
						elif (1.0 - y_component) < DEBUG_MIN:
							DEBUG_MIN = (1.0 - y_component)
						
						data[index] = final_value
						index += 1
			_regions[rx][rz].scalars = data
	print("Min: %s, Max: %s" % [DEBUG_MIN, DEBUG_MAX])
