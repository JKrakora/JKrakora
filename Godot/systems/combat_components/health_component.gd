class_name HealthComponent
extends Node

@export var hurtbox: Hurtbox
@export var health_amount: int= 10

signal on_damage_taken
signal on_health_depleted

func _ready() -> void:
	if hurtbox: hurtbox.on_hitbox_entered.connect(take_damage)


func take_damage(hitbox: Hitbox) -> void:
	if hitbox.damage_component:
		health_amount -= hitbox.damage_component.get_damage()
		on_damage_taken.emit()
		if health_amount <= 0:
			on_health_depleted.emit()
