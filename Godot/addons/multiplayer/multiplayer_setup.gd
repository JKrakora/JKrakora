@tool
extends EditorPlugin

const NAME = "Multiplayer"

func _enable_plugin() -> void:
	add_autoload_singleton(NAME, "res://addons/multiplayer/multiplayer.gd")
	ProjectSettings.set_setting("application/run/main_scene", "uid://b8l1yoi5p74wg")
	ProjectSettings.save()
	

func _disable_plugin() -> void:
	remove_autoload_singleton(NAME)
	ProjectSettings.set_setting("application/run/main_scene", "")
	ProjectSettings.save()
