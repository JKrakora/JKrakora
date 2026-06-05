class_name ItemSlot
extends Control

@export var item_data: ItemData
@export var label: Label
@export_category("Preview")
@export var preview_rect: TextureRect
@export var preview_width: float= 32
@export var preview_height: float= 32

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
	
	if label: 
		label.text = str(item_data)


func get_data() -> ItemData:
	return item_data


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
	if item_data and data["SupplicantItemData"].ID == item_data.ID:
		var sum = data["SupplicantItemData"].amount + item_data.amount
		var overflow = maxi(sum - item_data.max_amount, 0)
		
		data["SupplicantItemData"].amount = sum - overflow
		if overflow <= 0:
			item_data = null
		else: 
			item_data.amount = overflow
	
	data["SupplicantSlot"].set_data(item_data)
	set_data(data["SupplicantItemData"])


func _to_string() -> String:
	return "%s holding:%s" % [name, item_data]
