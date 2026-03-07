@tool
extends EditorPlugin

const NAME = "Multiplayer"

func _enable_plugin() -> void:
	add_autoload_singleton(NAME, "res://addons/my_lan_multiplayer/multiplayer.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton(NAME)
