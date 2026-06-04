class_name StackableItemData
extends ItemData

@export var amount:= 1
@export var max_amount:= 9999

func _to_string() -> String:
	return "%s:(%s/%s)" % [ID, amount, max_amount]
