extends Node3D

@export var world_chunk_count:= Vector3i(1, 1, 1)
@export var chunk_voxel_count: int= 2
var world_size_logical: Vector3i
var chunk_atlas: Dictionary[Vector3i, Chunk]

func _ready() -> void:
	_fill_atlas()


func _fill_atlas() -> void:
	world_size_logical = world_chunk_count * chunk_voxel_count
	
	for cx in range(world_chunk_count.x):
		for cy in range(world_chunk_count.y):
			for cz in range(world_chunk_count.z):
				var chunk_data = ChunkData.new()
				
				var data: Array[float] = []
				data.resize(chunk_voxel_count ** 3)
				var index = 0
				for x in range(chunk_voxel_count):
					for y in range(chunk_voxel_count):
						for z in range(chunk_voxel_count):
							data[index] = index
							index += 1
				chunk_data.voxel_values = data
				
				var chunk = Chunk.new()
				chunk.data = chunk_data
				chunk.voxel_count = chunk_voxel_count
				chunk_atlas[Vector3i(cx, cy, cx)] = chunk


func get_chunk_data(chunk_coord: Vector3i, skirted:= true) -> Array:
	if not skirted:
		return chunk_atlas[chunk_coord].data.voxel_values
	
	var values = []
	
	for i in range(chunk_voxel_count):
		for j in range(chunk_voxel_count):
			for r in range(chunk_voxel_count):
				values.append(_red(chunk_coord, r, j, i))
			values.append(_orange(chunk_coord, j, i))
		for y in range(chunk_voxel_count):
			values.append(_yellow(chunk_coord, y, i))
		values.append(_lime(chunk_coord, i))
	for i in range(chunk_voxel_count):
		for g in range(chunk_voxel_count):
			values.append(_green(chunk_coord, g, i))
		values.append(_blue(chunk_coord, i))
	for i in range(chunk_voxel_count):
		values.append(_indigo(chunk_coord, i))
	values.append(_purple(chunk_coord))
	
	return values


func _red(coord: Vector3i, r: int, j: int, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(0, 0, 0))].get_voxel_value(r + (chunk_voxel_count * j) + (chunk_voxel_count ** 2 * i))
func _orange(coord: Vector3i, j: int, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(0, 0, 1))].get_voxel_value(j * chunk_voxel_count) + (chunk_voxel_count ** 2 * i)
func _yellow(coord: Vector3i, y: int, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(1, 0, 0))].get_voxel_value(chunk_voxel_count ** 2 * i + y)
func _lime(coord: Vector3i, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(1, 0, 1))].get_voxel_value(chunk_voxel_count ** 2 * i)
func _green(coord: Vector3i, g: int, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(0, 1, 0))].get_voxel_value(g + (chunk_voxel_count * i))
func _blue(coord: Vector3i, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(0, 1, 1))].get_voxel_value(i * chunk_voxel_count)
func _indigo(coord: Vector3i, i: int) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(1, 1, 0))].get_voxel_value(i)
func _purple(coord: Vector3i) -> float:
	return chunk_atlas[get_atlas_coord(coord + Vector3i(1, 1, 1))].get_voxel_value(0)


func get_atlas_coord(coord: Vector3i) -> Vector3i:
	return Vector3i(
		coord.x % world_chunk_count.x,
		coord.y % world_chunk_count.y,
		coord.z % world_chunk_count.z,
	)
