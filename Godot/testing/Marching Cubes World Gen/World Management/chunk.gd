class_name Chunk
extends Node3D

@onready var collision:= $StaticBody3D/CollisionShape3D
@onready var visual:= $StaticBody3D/CollisionShape3D/MeshInstance3D

var idle_time_seconds: float

func set_mesh(array_mesh: ArrayMesh) -> void:
	if visual: 
		visual.mesh = array_mesh
	
	if array_mesh and collision: 
		collision.shape = array_mesh.create_trimesh_shape()
