class_name SmoothCamera3D
extends Camera3D

@export var target: Node3D

func _ready() -> void:
	top_level = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON


func _process(_delta: float) -> void:
	global_position = target.get_global_transform_interpolated().origin
