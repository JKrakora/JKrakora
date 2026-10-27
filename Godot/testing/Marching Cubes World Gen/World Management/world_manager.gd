extends Node

## NOTE: WorldData.WorldData.get_mc_chunk_data() is a bottleneck
@export var player: Node3D

## == Ticks ===
var tick_timer: Timer
@export var tick_interval_seconds:= 0.05
@export var max_adds_per_tick: int= 10
@export var max_removes_per_tick: int= 15

## === Data ===
var world_data: WorldData
@export var force_new_gen:= false

## === Chunk ===
@export var chunk_size: int= 16
@export var voxel_size: float= 1.0
var chunk_volume: int= 0
var current_chunk:= Vector2i.ZERO
var previous_chunk:= Vector2i.MAX
@export var chunk_load_radius: int= 5
@export var chunk_unload_additive: int= 2
@export var chunk_idle_timeout_seconds:= 10.0

## === Queues ===
var active_chunks: Dictionary[Vector2i, Chunk]= {}
var add_queue:= PriorityQueue.new()
var add_lookup: Dictionary= {}
var remove_queue:= Queue.new()
var remove_lookup: Dictionary= {}
var compute_queue:= PriorityQueue.new()
var compute_lookup: Dictionary= {}
var mesh_queue:= Queue.new()
var mesh_lookup: Dictionary= {}
var mesh_ids: Dictionary= {}

## === Compute Shader Stuff ===
var rendering_device: RenderingDevice
var shader: RID
var pipeline: RID

var buffer_set: RID
var input_buffer: RID
const INPUT_BINDING:= 0
var output_buffer: RID
const OUTPUT_BINDING:= 1
var counter_buffer: RID
const COUNTER_BINDING:= 2

const GPU_WAITFRAME_COUNT: int= 3
var hotseat: Dictionary= {}
var frame: int
var compute_dispatch_frame: int

func _ready() -> void:
	load_world(Refs.TEST_WORLD_SAVE_PATH) ## DEBUG
	
	setup_compute()
	setup_timer()


func _process(delta: float) -> void:
	if player:
		#player.position.x += 5.0 * delta
		var chunk_size_physical = chunk_size * voxel_size
		current_chunk = Vector2i(
			floori(player.position.x / chunk_size_physical),
			floori(player.position.z / chunk_size_physical)
		)
	
	if current_chunk != previous_chunk:
		check_for_new_chunks()
		previous_chunk = current_chunk
	update_active_chunks(delta)
	frame += 1


func _process_tick() -> void:
	check_remove_queue()
	check_add_queue()
	
	check_compute_queue()
	check_compute_status()
	
	check_mesh_queue()
	check_mesh_threads()


func load_world(world_path: String) -> void:
	world_data = Util.load_resource_from(world_path)
	if not world_data or force_new_gen:
		world_data = WorldData.new()
		world_data.generate_world(5)
	
	if has_node("MeshInstance3D2"):
		$MeshInstance3D2.position.y = world_data.world_size.y


func check_for_new_chunks() -> void:
	for x in range(-chunk_load_radius, chunk_load_radius + 1):
		for z in range(-chunk_load_radius, chunk_load_radius + 1):
			var coord = current_chunk + Vector2i(x, z)
			var distance = current_chunk.distance_to(coord)
			if distance <= chunk_load_radius:
				add_to_add_queue(coord, distance)


func update_active_chunks(delta: float) -> void:
	for coord in active_chunks:
		var distance = current_chunk.distance_to(coord)
		if distance <= chunk_load_radius:
			active_chunks[coord].idle_time_seconds = 0.0
		elif distance < chunk_load_radius + chunk_unload_additive:
			active_chunks[coord].idle_time_seconds += delta
			if active_chunks[coord].idle_time_seconds >= chunk_idle_timeout_seconds:
				add_to_remove_queue(coord)
		else:
			add_to_remove_queue(coord)


func add_to_add_queue(coord: Vector2i, distance: float) -> void:
	if active_chunks.has(coord):
		return
	
	if add_lookup.has(coord):
		return
	
	if remove_lookup.has(coord):
		remove_lookup.erase(coord)
	
	add_lookup[coord] = true
	add_queue.push(coord, distance)


func check_add_queue() -> void:
	var counter = 0
	while add_queue.size() > 0 and counter < max_adds_per_tick:
		var coord = add_queue.pop()
		if not add_lookup.has(coord):
			continue
		
		add_lookup.erase(coord)
		if active_chunks.has(coord):
			continue
		
		add_to_compute_queue(coord, coord.distance_to(current_chunk))
		var chunk = Refs.CHUNK_SCENE.instantiate()
		chunk.name = "Chunk(%s,%s)" % [coord.x, coord.y]
		var pos = coord * chunk_size * voxel_size
		chunk.position.x = pos.x
		chunk.position.z = pos.y
		active_chunks[coord] = chunk
		$"Chunk Holder".add_child.call_deferred(chunk, true)
		counter += 1


func add_to_remove_queue(coord: Vector2i) -> void:
	if not active_chunks.has(coord):
		return
	
	if remove_lookup.has(coord):
		return
	
	if add_lookup.has(coord):
		add_lookup.erase(coord)
	
	remove_lookup[coord] = true
	remove_queue.push(coord)


func check_remove_queue() -> void:
	var counter = 0
	while remove_queue.size() > 0 and counter < max_removes_per_tick:
		var coord = remove_queue.pop()
		if not remove_lookup.has(coord):
			continue
		
		remove_lookup.erase(coord)
		if not active_chunks.has(coord):
			continue
		
		var chunk = active_chunks[coord]
		if not is_instance_valid(chunk):
			continue
		
		## save things if necessary
		chunk.queue_free()
		active_chunks.erase(coord)
		counter += 1


func add_to_compute_queue(coord: Vector2i, distance: float) -> void:
	if compute_lookup.has(coord):
		return
	
	compute_lookup[coord] = true
	compute_queue.push(coord, distance)


func check_compute_queue() -> void:
	if hotseat:
		return
	
	if compute_queue.size() == 0:
		return
	
	var coord = compute_queue.pop()
	if not compute_lookup.has(coord):
		return
	
	compute_lookup.erase(coord)
	if not active_chunks.has(coord):
		return
	
	run_compute(coord)


func setup_compute() -> void:
	chunk_volume = world_data.get_chunk_volume(chunk_size)
	
	rendering_device = RenderingServer.create_local_rendering_device()
	var shader_spirv: RDShaderSPIRV= Refs.MC_COMPUTE_SHADER.get_spirv()
	shader = rendering_device.shader_create_from_spirv(shader_spirv)
	
	var input_bytes = []
	input_bytes.resize(chunk_volume)
	input_bytes = PackedFloat32Array(input_bytes).to_byte_array()
	input_buffer = rendering_device.storage_buffer_create(input_bytes.size(), input_bytes)
	var input_uniform:= RDUniform.new()
	input_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	input_uniform.binding = INPUT_BINDING
	input_uniform.add_id(input_buffer)
	
	const MAX_TRIS_PER_VOXEL: int= 5 ## per marching cubes algorithm
	var max_triangles:= MAX_TRIS_PER_VOXEL * chunk_volume
	const BYTES_PER_FLOAT:= 4 ## per float32s being 32-bit; 32/8 = 4
	const FLOATS_PER_TRI:= 4 * 4 ## per having 4 vec4s;
	var bytes_per_triangle:= FLOATS_PER_TRI * BYTES_PER_FLOAT
	var max_bytes:= bytes_per_triangle * max_triangles
	output_buffer = rendering_device.storage_buffer_create(max_bytes)
	var output_uniform = RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	output_uniform.binding = OUTPUT_BINDING
	output_uniform.add_id(output_buffer)
	
	var counter_bytes = PackedInt32Array([0]).to_byte_array()
	counter_buffer = rendering_device.storage_buffer_create(counter_bytes.size(), counter_bytes)
	var counter_uniform:= RDUniform.new()
	counter_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	counter_uniform.binding = COUNTER_BINDING
	counter_uniform.add_id(counter_buffer)
	
	var buffers = [input_uniform, output_uniform, counter_uniform]
	buffer_set = rendering_device.uniform_set_create(buffers, shader, 0)
	pipeline = rendering_device.compute_pipeline_create(shader)


func run_compute(coord: Vector2i) -> void:
	var input_bytes = world_data.get_mc_chunk_data(coord * chunk_size, chunk_size).to_byte_array()
	rendering_device.buffer_update(input_buffer, 0, input_bytes.size(), input_bytes)
	var counter_bytes = PackedInt32Array([0]).to_byte_array()
	rendering_device.buffer_update(counter_buffer, 0, counter_bytes.size(), counter_bytes)
	
	var push_constants:= PackedByteArray()
	push_constants.resize(6 * 4)
	push_constants.encode_float(0, coord.x)
	push_constants.encode_float(4, 0.0)
	push_constants.encode_float(8, coord.y)
	push_constants.encode_float(12, 0.0) ## ISOLEVEL
	push_constants.encode_s32(16, chunk_size)
	push_constants.encode_s32(20, world_data.REGION_HEIGHT)
	
	var compute_list = rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, buffer_set, 0)
	rendering_device.compute_list_set_push_constant(compute_list, push_constants, push_constants.size())
	rendering_device.compute_list_dispatch(compute_list, ceili(chunk_volume / 256.0), 1, 1)
	rendering_device.compute_list_end()
	
	rendering_device.submit()
	hotseat = { "coord": coord, "submit_frame": frame }


func check_compute_status() -> void:
	if hotseat and frame - hotseat.submit_frame >= GPU_WAITFRAME_COUNT:
		rendering_device.sync()
		var triangle_count = rendering_device.buffer_get_data(counter_buffer).to_int32_array()[0]
		if triangle_count > 0:
			add_to_mesh_queue({
				"coord": hotseat.coord,
				"output_bytes": rendering_device.buffer_get_data(output_buffer),
				"triangle_count": triangle_count
			})
		hotseat = {}


func add_to_mesh_queue(data: Dictionary) -> void:
	var coord = data.coord
	if mesh_lookup.has(coord):
		return
	
	if not active_chunks.has(coord):
		return
	
	mesh_lookup[coord] = true
	mesh_queue.push(data)


func check_mesh_queue() -> void:
	if mesh_queue.size() == 0:
		return
	
	var args = mesh_queue.pop()
	var coord = args.coord
	if not mesh_lookup.has(coord):
		return
	
	mesh_lookup.erase(coord)
	if not active_chunks.has(coord):
		return
	
	var id = Util.add_task_to_queue(make_surface_array, args)
	mesh_ids[id] = { "coord": coord }


func make_surface_array(args: Dictionary) -> Dictionary:
	var data = args.output_bytes.to_float32_array()
	
	var vertices:= PackedVector3Array()
	#var uvs:= PackedVector2Array()
	var normals:= PackedVector3Array()
	#var indices:= PackedInt32Array()
	
	for tri_index in range(args.triangle_count):
		var index = tri_index * 16
		vertices.append(Vector3(data[index + 0], data[index + 1], data[index + 2]))
		vertices.append(Vector3(data[index + 4], data[index + 5], data[index + 6]))
		vertices.append(Vector3(data[index + 8], data[index + 9], data[index + 10]))
		
		var normal = Vector3(data[index + 12], data[index + 13], data[index + 14])
		normals.append(normal)
		normals.append(normal)
		normals.append(normal)
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	#surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	#surface_array[Mesh.ARRAY_INDEX] = indices
	
	return { "coord": args.coord, "array": surface_array }


func check_mesh_threads() -> void:
	for id in mesh_ids.keys():
		if Util.is_worker_finished(id):
			var result = Util.get_worker_result(id)
			if active_chunks.has(result.coord):
				var array_mesh = ArrayMesh.new()
				if result.array[Mesh.ARRAY_VERTEX].size() > 0:
					array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, result.array)
				active_chunks[result.coord].set_mesh(array_mesh)
			mesh_ids.erase(id)


func setup_timer() -> void:
	tick_timer = Timer.new()
	tick_timer.wait_time = tick_interval_seconds
	tick_timer.one_shot = false
	tick_timer.autostart = true
	tick_timer.timeout.connect(_process_tick)
	add_child(tick_timer)
