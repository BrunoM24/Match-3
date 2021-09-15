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

var first_touch = Vector2.ZERO
var final_touch = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pieces = make_2d_array()
	spawn_pieces()


func _physics_process(delta):
	touch_input()


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
			while(match_at(i, j, piece.color)):
				piece = possible_pieces[randi() % possible_pieces.size() - 1].instance()
			piece.position = grid_to_pixel(i, j)
			add_child(piece)
			pieces[i][j] = piece


func match_at(column, row, color):
	if column > 1:
		if pieces[column - 1][row] != null && pieces[column - 2][row] != null:
			if pieces[column - 1][row].color == color && pieces[column - 2][row].color == color:
				return true
				
	if row > 1:
		if pieces[column][row - 1] != null && pieces[column][row - 2] != null:
			if pieces[column][row - 1].color == color && pieces[column][row - 2].color == color:
				return true


func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(mouse_position: Vector2):
	var column = round((mouse_position.x - x_start) / offset)
	var row = round((mouse_position.y - y_start) / -offset)
	return Vector2(column, row)


func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var grid_position = pixel_to_grid(first_touch)
		print(grid_position)
	if Input.is_action_just_released("ui_touch"):
		final_touch = get_local_mouse_position()
		var grid_position = pixel_to_grid(final_touch)
		print(grid_position)
	
	pass

