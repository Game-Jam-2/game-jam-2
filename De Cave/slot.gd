extends Control

@export var item_texture: Texture2D
@onready var texture_rect = $TextureRect

func _ready():
	texture_rect.texture = item_texture
