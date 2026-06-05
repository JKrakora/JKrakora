class_name ItemData
extends Resource

@export var ID: int
@export var name: String
@export var icon: Texture2D

@export var amount:= 1
@export var max_amount:= 9999

func _to_string() -> String:
	return "%s[%s]: (%s/%s)" % [name, ID, amount, max_amount]
