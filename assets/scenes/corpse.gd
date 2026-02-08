extends "res://assets/scenes/system/text_object.gd"

@export var textures: Array[Texture]
func _ready() -> void:
	$Sprite2D.texture = textures.pick_random()
