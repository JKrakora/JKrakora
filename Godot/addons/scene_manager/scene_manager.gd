extends Node

const _LOADING_SCREEN = "uid://5dxi85bbgrrw"

func change_scene(file_path : String) -> void:
	get_tree().call_deferred(
		"change_scene_to_file", 
		_LOADING_SCREEN
	)
	await get_tree().process_frame
	
	var loading_screen = get_tree().root.get_node("Loading Screen")
	loading_screen.load_file(file_path)
	
	var finished_scene = await loading_screen.scene_finished_loaded
	get_tree().call_deferred(
		"change_scene_to_packed", 
		ResourceLoader.load_threaded_get(finished_scene)
	)
