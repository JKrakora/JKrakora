class_name SpawnPoint
extends Node3D

var time : float = 3.0
var assumed_unoccupied_time : float = 3.0

func _process(delta: float) -> void:
	time += delta


func get_info() -> Vector4:
	time = 0
	return Vector4(
		global_position.x,
		global_position.y,
		global_position.z,
		rotation.y,
	)


func is_occupied() -> bool:
	return time <= assumed_unoccupied_time
