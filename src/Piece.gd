extends Node2D


export (String) var color

onready var move_tween = $MoveTween

var matched = false

func move(target):
	move_tween.interpolate_property(self, "position", position, target, .3, 
	Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	
	move_tween.start()


func dim():
	$Sprite.self_modulate = Color(1, 1, 1, .5)

