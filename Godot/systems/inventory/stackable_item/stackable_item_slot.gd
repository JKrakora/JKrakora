class_name StackableItemSlot
extends ItemSlot

@export var label: Label

func set_data(data: ItemData) -> void:
	super(data)
	
	if label: 
		label.text = str(item_data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if item_data and data["SupplicantItemData"] is StackableItemData and data["SupplicantItemData"].ID == item_data.ID:
		var sum = data["SupplicantItemData"].amount + item_data.amount
		var overflow = maxi(sum - item_data.max_amount, 0)
		
		data["SupplicantItemData"].amount = sum - overflow
		if overflow <= 0: 
			item_data = null
		else: 
			item_data.amount = overflow
	
	super(_at_position, data)


func _to_string() -> String:
	return "%s: %s" % [name, item_data]
