class_name InventorySlot
extends Panel

@export var item_data: ItemData

func set_data(data: ItemData) -> void:
	if data:
		$TextureRect.texture = data.image
		item_data = data
	else:
		$TextureRect.texture = null
		item_data = null

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not item_data:
		return null
	
	var preview = TextureRect.new()
	preview.texture = item_data.image
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = Vector2(32, 32)
	
	set_drag_preview(preview)
	
	return {
		"ItemData": item_data,
		"TakenFrom": self
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.has("ItemData")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data["TakenFrom"].set_data(item_data)
	set_data(data["ItemData"])
