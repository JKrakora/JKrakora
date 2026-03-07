extends Node

@onready var level_holder := $"Level Holder"
@onready var _level_spawner := $"Level Spawner"
@export var levels : Array[String]
@onready var player_holder := $"Player Holder"
@onready var _player_spawner := $"Player Spawner"
@export var player : String


func _ready() -> void:
	for level in levels:
		_level_spawner.add_spawnable_scene(level)
	_player_spawner.add_spawnable_scene(player)
	_player_spawner.spawn_function = _custom_spawn_function


func _custom_spawn_function(id : int) -> Node:
	var new_player = load(player).instantiate()
	new_player.name = str(id)
	new_player.position = Vector3.ZERO
	new_player.set_multiplayer_authority(id)
	return new_player


func change_level(index := 0) -> void:
	for item in level_holder.get_children():
		level_holder.remove_child(item)
		item.queue_free()
	if index == -1:
		return
	
	var level = load(levels[index]).instantiate()
	level.player_spawner = _player_spawner
	level.player_holder = player_holder
	level_holder.add_child(level)


func _on_host_pressed() -> void:
	var error = Multiplayer.host()
	if error:
		print("\thosting error: %s" % error)
		return
	change_level.call_deferred()


func _on_join_pressed() -> void:
	var error = Multiplayer.join()
	if error:
		print("\tjoining error: %s" % error)
		return


func _on_leave_pressed() -> void:
	if multiplayer.is_server():
		change_level.call_deferred(-1)
	for child in player_holder.get_children():
		player_holder.remove_child(child)
		child.queue_free()
	Multiplayer.leave()
