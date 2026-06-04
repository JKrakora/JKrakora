class_name ItemSlot
extends Control

@export var item_data: ItemData
@export_category("Preview")
@export var preview_rect: TextureRect
@export var preview_width: float= 50
@export var preview_height: float= 50

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	for child in get_children(true):
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_PASS
	set_data(item_data)


func set_data(data: ItemData) -> void:
	item_data = data
	
	if preview_rect:
		preview_rect.texture = item_data.icon if item_data else null


func get_drag_preview() -> Control:
	var preview = TextureRect.new()
	
	preview.texture = item_data.icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = Vector2(preview_width, preview_height)
	
	return preview


func _get_drag_data(_at_position: Vector2) -> Variant:
	if not item_data: 
		return null
	
	set_drag_preview(get_drag_preview())

	return { 
		"SupplicantItemData": item_data, 
		"SupplicantSlot": self 
	}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.has("SupplicantItemData") and data.has("SupplicantSlot")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data["SupplicantSlot"].set_data(item_data)
	set_data(data["SupplicantItemData"])


func _to_string() -> String:
	return "%s: %s" % [name, item_data]
