extends CharacterBody3D

func _ready() -> void:
    set_multiplayer_authority(multiplayer.get_unique_id())
    # Set other related things such as camera or synchronizer authority
