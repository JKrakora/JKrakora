class_name ItemData
extends Resource

@export var ID: int
@export var name: String
@export var icon: Texture2D

func _to_string() -> String:
	return "%s" % name
