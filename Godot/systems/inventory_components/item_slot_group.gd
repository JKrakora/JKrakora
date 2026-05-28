class_name ItemSlotGroup
extends Control

var slots: Array[ItemSlot]

func _ready() -> void:
	_collect_slot_children()


func set_all_slot_data(data_array: Array[ItemData]) -> void:
	var index = 0
	while index < slots.size() and index < data_array.size():
		slots[index].set_data(data_array[index])
		index += 1


func get_all_slot_data() -> Array[ItemData]:
	var data_array: Array[ItemData]= []
	for slot in slots:
		data_array.append(slot.get_data())
	return data_array


func set_slot_data(data: ItemData, index: int) -> void:
	if index >= slots.size() or index < 0:
		return
	slots[index].set_data(data)


func get_slot_data(index: int) -> ItemData:
	if index >= slots.size() or index < 0:
		return null
	return slots[index].get_data()


func _collect_slot_children() -> void:
	slots.clear()
	for child in get_children():
		if child is ItemSlot:
			slots.append(child)
