extends Node

signal player_connected(id: int)
signal player_disconnected(id: int)

signal join_game()
signal host_leave_game()
signal client_leave_game()

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_successful)
	multiplayer.connection_failed.connect(_on_connection_unsuccessful)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func create_lobby(port : int) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error:
		OS.alert("Failed to create lobby, Error: %s" % error)
		return
	multiplayer.multiplayer_peer = peer
	join_game.emit()


func join_lobby(address : String, port : int) -> void:
	if multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		return
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		OS.alert("Failed to join lobby, Error: %s" % error)
		return
	multiplayer.multiplayer_peer = peer
	join_game.emit()


func leave_lobby() -> void:
	if multiplayer.is_server():
		host_leave_game.emit()
	else:
		client_leave_game.emit()
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_player_connected(id: int) -> void:
	player_connected.emit(id)


func _on_player_disconnected(id: int) -> void:
	player_disconnected.emit(id)


func _on_connection_successful() -> void:
	pass


func _on_connection_unsuccessful() -> void:
	pass


func _on_server_disconnected() -> void:
	client_leave_game.emit()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
