class_name SpawnPoint
extends Node3D

func get_info() -> Vector4:
	return Vector4(
		global_position.x,
		global_position.y,
		global_position.z,
		global_rotation.y,
	)
