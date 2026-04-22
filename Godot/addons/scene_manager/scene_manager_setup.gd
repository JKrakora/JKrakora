@tool
extends EditorPlugin

const NAME = "SceneManager"
func _enable_plugin() -> void:
	add_autoload_singleton(NAME, "res://addons/scene_manager/Scene Manager.tscn")

func _disable_plugin() -> void:
	remove_autoload_singleton(NAME)
