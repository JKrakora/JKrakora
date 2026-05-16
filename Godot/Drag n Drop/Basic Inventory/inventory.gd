class_name Inventory
extends GridContainer

@export var items : Array[ItemData]
var slots: Array[InventorySlot]
@export var rows:= 1

const SLOT = preload("uid://dtsbvu8l1nipp")
func _ready() -> void:
	for index in range(max(items.size(), rows * columns)):
		var slot = SLOT.instantiate() as InventorySlot
		if index >= items.size():
			slot.set_data(null)
		else:
			slot.set_data(items[index])
		slots.append(slot)
		add_child(slot, true)
