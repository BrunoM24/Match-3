extends Node2D


export (String) var color

onready var move_tween = $MoveTween


func move(target):
	move_tween.interpolate_property(self, "position", position, target, .3, 
	Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	
	move_tween.start()
