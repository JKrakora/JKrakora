extends Node

@export var player_scene : String
@export var levels : Array[String]

@onready var UI = $UI
@onready var level_holder = $"Level Holder"
var current_level : Level
@onready var level_spawner = $"Level Spawner"
@onready var player_holder = $"Player Holder"
@onready var player_spawner = $"Player Spawner"

func _ready() -> void:
	Multiplayer.join_game.connect(load_into_lobby)
	Multiplayer.host_leave_game.connect(close_lobby)
	Multiplayer.client_leave_game.connect(leave_lobby)
	
	Multiplayer.player_connected.connect(_add_player)
	Multiplayer.player_disconnected.connect(_remove_player)
	
	player_spawner.spawn_function = _spawn_function
	player_spawner.add_spawnable_scene(player_scene)
	
	for level in levels:
		level_spawner.add_spawnable_scene(level)
	
	UI.make_pregame_ready()


func load_into_lobby() -> void:
	UI.make_ingame_ready()
	if not multiplayer.is_server():
		return
	
	change_level(levels[index])
	
	for peer in multiplayer.get_peers():
		_add_player(peer)
	
	if not OS.has_feature("dedicated_server"):
		_add_player(1)


func close_lobby() -> void:
	UI.make_pregame_ready()
	
	for peer in multiplayer.get_peers():
		_remove_player(peer)
	_remove_player(1)
	
	change_level()


func leave_lobby() -> void:
	UI.make_pregame_ready()


var index = 0
func change_level(to_file := "") -> void:
	if not multiplayer.is_server():
		return
	
	for child in level_holder.get_children():
		level_holder.remove_child(child)
		child.queue_free()
	
	if to_file.is_empty():
		current_level = null
		return
	
	current_level = load(to_file).instantiate()
	level_holder.add_child(current_level)

	current_level.reset_spawn_point_occupancy()
	for player in player_holder.get_children():
		player = _get_and_set_spawn_position(player)


func _add_player(id: int) -> void:
	if is_multiplayer_authority():
		player_spawner.spawn(id)


func _remove_player(id: int) -> void:
	if player_holder.has_node(str(id)):
		player_holder.get_node(str(id)).call_deferred("queue_free")


func _spawn_function(id : int) -> Node:
	var player = load(player_scene).instantiate()
	player.set_multiplayer_authority(id)
	player.name = str(id)
	player = _get_and_set_spawn_position(player)
	
	return player


func _get_and_set_spawn_position(player) -> CharacterBody3D:
	var spawn_point = Vector4()
	if current_level:
		current_level.get_spawn_point()
	
	player.rotation.y = spawn_point.w
	player.position.x = spawn_point.x
	player.position.y = spawn_point.y
	player.position.z = spawn_point.z
	
	return player
