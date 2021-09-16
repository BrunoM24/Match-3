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
var controlling = false


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
		if is_in_grid(pixel_to_grid(get_global_mouse_position())):
			first_touch = pixel_to_grid(get_global_mouse_position())
			controlling = true
	
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position())) && controlling:
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position())
			touch_difference(first_touch, final_touch)


func is_in_grid(grid_position: Vector2):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	
	return false


func swap_pieces(column, row, direction):
	var first_piece = pieces[column][row]
	var other_piece = pieces[column + direction.x][row + direction.y]
	
	if first_piece != null && other_piece != null:
		pieces[column][row] = other_piece
		pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		find_matches()


func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.RIGHT)
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.LEFT)
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.DOWN)
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.UP)


func find_matches():
	for col in width:
		for row in height:
			if pieces[col][row] != null:
				var color = pieces[col][row].color
				
				if col > 0 && col < width - 1:
					if pieces[col - 1][row] != null && pieces[col + 1][row] != null:
						if pieces[col - 1][row].color == color && pieces[col + 1][row].color == color:
							pieces[col - 1][row].matched = true
							pieces[col - 1][row].dim()
							pieces[col][row].matched = true
							pieces[col][row].dim()
							pieces[col + 1][row].matched = true
							pieces[col + 1][row].dim()
				
				if row > 0 && row < height - 1:
					if pieces[col][row - 1] != null && pieces[col][row + 1] != null:
						if pieces[col][row - 1].color == color && pieces[col][row + 1].color == color:
							pieces[col][row - 1].matched = true
							pieces[col][row - 1].dim()
							pieces[col][row].matched = true
							pieces[col][row].dim()
							pieces[col][row + 1].matched = true
							pieces[col][row + 1].dim()
	
	get_parent().get_node("DestroyTimer").start()


func destroy_matches():
	for col in width:
		for row in height:
			if pieces[col][row] != null:
				if pieces[col][row].matched:
					pieces[col][row].queue_free()
					pieces[col][row] = null
	
	get_parent().get_node("CollapseTimer").start()


func collapse_collumns():
	for col in width:
		for row in height:
			if pieces[col][row] == null:
				for i in range(row + 1, height):
					if pieces[col][i] != null:
						pieces[col][i].move(grid_to_pixel(col, row))
						pieces[col][row] = pieces[col][i]
						pieces[col][i] = null
						break

func _on_DestroyTimer_timeout():
	destroy_matches()


func _on_CollapseTimer_timeout():
	collapse_collumns()

