class_name Level
extends Node

signal change_level_request(level: String)
var spawn_points : Array[SpawnPoint]

func _ready() -> void:
	_resursive_search_for_spawn_points(self)


func get_spawn_point() -> Vector4:
	if spawn_points:
		return spawn_points.pick_random().get_info()
	return Vector4()


func _resursive_search_for_spawn_points(node: Node) -> void:
	for child in node.get_children():
		if child is SpawnPoint:
			spawn_points.append(child)
		_resursive_search_for_spawn_points(child)
