class_name ItemData
extends Resource

@export var name: String= "PLACEHOLDER"
@export var image: Texture2D

func _to_string() -> String:
	return "%s" % name
