class_name Hitbox
extends Area3D
# Does the Hit

@export var damage_component: DamageComponent

signal on_entered_hurtbox(hurtbox: Hurtbox)
func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox: 
		on_entered_hurtbox.emit(area)
