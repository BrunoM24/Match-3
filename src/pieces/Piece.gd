extends Node2D


export (String) var color
export (Texture) var row_texture
export (Texture) var column_texture
export (Texture) var adjacent_texture

var is_row_bomb = false
var is_column_bomb = false
var is_adjacent_bomb = false

onready var move_tween := $MoveTween
onready var sprite := $Sprite

var matched = false

func move(target):
	move_tween.interpolate_property(self, "position", position, target, .3, 
	Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	
	move_tween.start()


func make_column_bomb() -> void:
	is_column_bomb = true
	sprite.texture = column_texture
	sprite.self_modulate = Color(1, 1, 1, 1)


func make_row_bomb() -> void:
	is_row_bomb = true
	sprite.texture = row_texture
	sprite.self_modulate = Color(1, 1, 1, 1)


func make_adjacent_bomb() -> void:
	is_adjacent_bomb = true
	sprite.texture = adjacent_texture
	sprite.self_modulate = Color(1, 1, 1, 1)


func dim():
	sprite.self_modulate = Color(1, 1, 1, .5)

