extends Node

signal scene_finished_loading(path: String)
@onready var _fade_screen = $FadeScreen
@onready var _progress_bar = $ProgressBar
var _load_path : String
var _tween

func _process(delta : float) -> void:
	if not _load_path:
		return
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(_load_path, progress)
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		_progress_bar.value = move_toward(_progress_bar.value, progress[0] * 100, delta * 20)
	elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		_progress_bar.value = move_toward(_progress_bar.value, 100, delta * 150)
		
		if _progress_bar.value >= 99:
			scene_finished_loading.emit(_load_path)


func swap_to_scene(file_path: String) -> void:
	get_tree().call_deferred(
		"change_scene_to_file",
		file_path
	)


func fade_to_scene(file_path: String, fade_in_time:= 0.5, fade_out_time:= 0.5) -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	await _tween.tween_property(_fade_screen, "color:a", 1, fade_in_time).finished
	swap_to_scene(file_path)
	_tween = get_tree().create_tween()
	await _tween.tween_property(_fade_screen, "color:a", 0, fade_out_time).finished


func load_to_scene(file_path: String, black_screen:= false) -> void:
	_load_path = file_path
	ResourceLoader.load_threaded_request(_load_path)
	
	_progress_bar.visible = true
	if black_screen:
		_fade_screen.color.a = 1
	
	var scene = await scene_finished_loading
	
	if black_screen:
		_fade_screen.color.a = 0
	_progress_bar.visible = false
	
	get_tree().call_deferred(
		"change_scene_to_packed",
		ResourceLoader.load_threaded_get(scene)
	)


func pause() -> void:
	get_tree().root.set_process(false)


func unpause() -> void:
	get_tree().root.set_process(true)
