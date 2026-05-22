extends Node

@export var levels : Array[String]
@onready var level_holder = $"Level Holder"
@onready var level_spawner = $"Level Spawner"

@export var player : String
@onready var player_holder = $"Player Holder"
@onready var player_spawner = $"Player Spawner"

@onready var UI = $UI

func _ready() -> void:
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	multiplayer.connected_to_server.connect(_on_connection_successful)
	multiplayer.connection_failed.connect(_on_connection_unsuccessful)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	for level in levels:
		level_spawner.add_spawnable_scene(level)
	player_spawner.add_spawnable_scene(player)
	
	UI.host_pressed.connect(create_lobby)
	UI.join_pressed.connect(join_lobby)
	UI.leave_pressed.connect(leave_lobby)


func create_lobby(port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error:
		OS.alert("Failed to create a Lobby, Error: %s" % error)
		return
	
	multiplayer.multiplayer_peer = peer
	UI.make_ingame_ready()
	change_level_to(levels[0])
	
	_add_player(1)
	for id in multiplayer.get_peers():
		_add_player(id)


func join_lobby(address: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		OS.alert("Failed to join Lobby, Error: %s" % error)
		return
	
	multiplayer.multiplayer_peer = peer
	UI.make_ingame_ready()


func leave_lobby() -> void:
	if multiplayer.is_server():
		for peer in multiplayer.get_peers():
			_remove_player(peer)
		_remove_player(1)
		change_level_to()
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	UI.make_pregame_ready()


func change_level_to(file:= "") -> void:
	if not multiplayer.is_server():
		return
	
	for child in level_holder.get_children():
		level_holder.call_deferred("remove_child", child)
		child.call_deferred("queue_free")
	
	if file.is_empty():
		return
	
	var new_level = load(file).instantiate()
	new_level.change_level_request.connect(change_level_to)
	level_holder.add_child(new_level)
	
	for peer in player_holder.get_children():
		_set_spawn_info_for(peer)


func _add_player(id: int) -> void:
	if not multiplayer.is_server():
		return
	
	var new_player = load(player).instantiate()
	new_player.name = str(id)
	player_holder.add_child(new_player, true)
	_set_spawn_info_for(new_player)


func _set_spawn_info_for(this_player) -> void:
	var spawn_point = Vector4()
	for child in level_holder.get_children():
		if child is Level:
			spawn_point = child.get_spawn_point()
			break
	
	this_player.position = Vector3(spawn_point.x, spawn_point.y, spawn_point.z)
	this_player.rotation.y = spawn_point.w


func _remove_player(id: int) -> void:
	if not multiplayer.is_server():
		return
	
	if player_holder.has_node(str(id)):
		player_holder.get_node(str(id)).call_deferred("queue_free")


func _on_connection_successful() -> void:
	pass


func _on_connection_unsuccessful() -> void:
	pass


func _on_server_disconnected() -> void:
	leave_lobby()
