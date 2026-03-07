class_name Level extends Node3D

var player_spawner
var player_holder

func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	Multiplayer.player_connected.connect(_add_player)
	Multiplayer.player_disconnected.connect(_remove_player)
	
	for peer_id in multiplayer.get_peers():
		_add_player(peer_id)
	
	if not OS.has_feature("dedicated_server"):
		_add_player(1)


func _add_player(id : int) -> void:
	await get_tree().create_timer(1).timeout #This fixes the non-origin spawning, but should be replaced with something more concrete
	player_spawner.spawn(id)


func _remove_player(id : int) -> void:
	if player_holder.has_node(str(id)):
		player_holder.get_node(str(id)).queue_free()
