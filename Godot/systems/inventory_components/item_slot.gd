class_name ItemSlot
extends Control

@export var item_data: ItemData
signal on_item_changed
@export var texture_rect: TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	for child in get_children(true):
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_PASS


func set_data(data: ItemData= null) -> void:
	if data == item_data:
		return
	
	item_data = data
	update_image()
	on_item_changed.emit()


func get_data() -> ItemData:
	return item_data


func update_image() -> void:
	if texture_rect:
		texture_rect.texture = item_data.image if item_data else null


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
	return data.has("ItemData") and data.has("TakenFrom")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data["TakenFrom"].set_data(item_data)
	set_data(data["ItemData"])


func _to_string() -> String:
	return "%s: %s" % [name, item_data]
