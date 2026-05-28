class_name Hurtbox
extends Area3D
# Gets the Hurt

signal on_hitbox_entered(hitbox: Hitbox)
func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if area is Hitbox: on_hitbox_entered.emit(area)
