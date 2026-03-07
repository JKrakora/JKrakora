class_name LoadingScreen
extends Control

signal scene_finished_loaded(path: String)
@onready var progress_bar = $CenterContainer/ProgressBar
var path : String

func _process(delta : float) -> void:
	if not path:
		return
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = move_toward(progress_bar.value, progress[0] * 100, delta * 20)
	elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		progress_bar.value = move_toward(progress_bar.value, 100, delta * 150)
		
		if progress_bar.value >= 99:
			scene_finished_loaded.emit(path)


func load_file(file_path : String) -> void:
	path = file_path
	ResourceLoader.load_threaded_request(path)
