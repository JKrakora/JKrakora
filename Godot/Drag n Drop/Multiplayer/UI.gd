extends CenterContainer

@onready var name_line = $VBoxContainer/PanelContainer/VBoxContainer/Name
@onready var address_line = $VBoxContainer/PanelContainer/VBoxContainer/Address
@onready var port_line = $VBoxContainer/PanelContainer/VBoxContainer/Port
@onready var host_button = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Host
@onready var join_button = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Join
@onready var leave_button = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Leave

func make_pregame_ready() -> void:
	_set_visibility_of_components(true, true, true, true, true, false)


func make_ingame_ready() -> void:
	_set_visibility_of_components(false, false, false, false, false, true)


func _set_visibility_of_components(given_name, address, port, host, join, leave) -> void:
	name_line.visible = given_name
	address_line.visible = address
	port_line.visible = port
	host_button.visible = host
	join_button.visible = join
	leave_button.visible = leave


signal host_pressed(port: int)
func _on_host_pressed() -> void:
	host_pressed.emit(port_line.text as int)


signal join_pressed(address: String, port: int)
func _on_join_pressed() -> void:
	join_pressed.emit(address_line.text as String, port_line.text as int)


signal leave_pressed()
func _on_leave_pressed() -> void:
	leave_pressed.emit()
