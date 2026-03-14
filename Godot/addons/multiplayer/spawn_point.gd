class_name SpawnPoint
extends Node3D

var is_occupied : bool

func get_info() -> Vector4:
	is_occupied = true
	return Vector4(
		global_position.x,
		global_position.y,
		global_position.z,
		rotation.y,
	)
