extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal server_disconnected

const _DEFAULT_PORT : int = 9999
const _DEFAULT_ADDRESS : String = "10.0.0.40"

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_successful)
	multiplayer.connection_failed.connect(_on_connection_unsuccessful)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func host(port := -1):
	if port == -1: port = _DEFAULT_PORT
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error: return error
	multiplayer.multiplayer_peer = peer


func join(address := "", port := -1):
	if address.is_empty(): address = _DEFAULT_ADDRESS
	if port == -1: port = _DEFAULT_PORT
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error: return error
	multiplayer.multiplayer_peer = peer


func leave():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_player_connected(id : int) -> void:
	print("%s: player %s connected" % [multiplayer.get_unique_id(), id])
	player_connected.emit(id)


func _on_player_disconnected(id : int) -> void:
	print("%s: player %s disconnected" % [multiplayer.get_unique_id(), id])
	player_disconnected.emit(id)


func _on_connection_successful() -> void:
	print("%s: Connection successful!" % multiplayer.get_unique_id())


func _on_connection_unsuccessful() -> void:
	print("%s: Connected unsuccessful!" % multiplayer.get_unique_id())
	leave()


func _on_server_disconnected() -> void:
	print("Server disconnected.")
	leave()
	server_disconnected.emit()
