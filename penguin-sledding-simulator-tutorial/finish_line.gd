extends TextureRect

@export var player: Player

func _ready() -> void:
	player.finish_x = global_position.x
