class_name ChunkData
extends Resource

@export var edge_voxel_count: int
@export var voxel_values: Array[float]

var _x_face: Array= []
var _y_face: Array= []
var _z_face: Array= []
var _xz_edge: Array= []
var _xy_edge: Array= []
var _yz_edge: Array= []
var _xyz_corner: Array= []

func get_x_face() -> Array:
	if _x_face.is_empty():
		_x_face.resize(edge_voxel_count ** 2)
		var index = 0 
		for y in range(edge_voxel_count):
			for z in range(edge_voxel_count):
				_x_face[index] = edge_voxel_count ** 2 * y + z
				index += 1
	
	return _get_array(_x_face)


func get_y_face() -> Array:
	if _y_face.is_empty():
		_y_face.resize(edge_voxel_count ** 2)
		var index = 0
		for x in range(edge_voxel_count):
			for z in range(edge_voxel_count):
				_y_face[index] = x * edge_voxel_count + z 
				index += 1
	
	return _get_array(_y_face)


func get_z_face() -> Array:
	if _z_face.is_empty():
		_z_face.resize(edge_voxel_count ** 2)
		var index = 0
		pass
	
	return _get_array(_y_face)


func get_xz_edge() -> Array:
	return _get_array(_y_face)


func get_xy_edge() -> Array:
	return _get_array(_y_face)


func get_yz_edge() -> Array:
	return _get_array(_y_face)


func get_xyz_corner() -> Array:
	return _get_array(_y_face)


func _get_array(indices: Array) -> Array:
	var values = []
	values.resize(indices.size())
	for i in range(indices.size()):
		values[i] = voxel_values[indices[i]]
	return values
