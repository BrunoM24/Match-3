extends Node2D


export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset

var pieces = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pieces = make_2d_array()
	print(pieces)


func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array
