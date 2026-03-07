extends CenterContainer

@onready var address = $VBoxContainer/PanelContainer/VBoxContainer/Address.text:
	get: return address as String
@onready var port = $VBoxContainer/PanelContainer/VBoxContainer/Port.text:
	get: return port as int

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


func _set_visibility_of_components(name, address, port, host, join, leave) -> void:
	name_line.visible = name
	address_line.visible = address
	port_line.visible = port
	host_button.visible = host
	join_button.visible = join
	leave_button.visible = leave


func _on_host_pressed() -> void:
	Multiplayer.create_lobby(port)


func _on_join_pressed() -> void:
	Multiplayer.join_lobby(address, port)


func _on_leave_pressed() -> void:
	Multiplayer.leave_lobby()
