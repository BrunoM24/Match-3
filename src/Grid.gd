extends Node2D


export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset

var pieces = []

var possible_pieces = [
	preload("res://src/BluePiece.tscn"),
	preload("res://src/GreenPiece.tscn"),
	preload("res://src/LightGreenPiece.tscn"),
	preload("res://src/OrangePiece.tscn"),
	preload("res://src/PinkPiece.tscn"),
	preload("res://src/OrangePiece.tscn")
]


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pieces = make_2d_array()
	spawn_pieces()


func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array


func spawn_pieces():
	for i in width:
		for j in height:
			var piece = possible_pieces[randi() % possible_pieces.size() - 1].instance()
			piece.position = grid_to_pixel(i, j)
			add_child(piece)



func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)

