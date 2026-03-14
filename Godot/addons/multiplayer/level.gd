class_name Level
extends Node

var spawn_points : Array

func _ready() -> void:
	_recursive_search_for_spawn_points(self)


func get_spawn_point() -> Vector4:
	for point in spawn_points:
		if not point.is_occupied:
			return point.get_info()
	return Vector4()


func _recursive_search_for_spawn_points(parent : Node) -> void:
	for child in parent.get_children():
		if child is SpawnPoint:
			spawn_points.append(child)
		_recursive_search_for_spawn_points(child)
