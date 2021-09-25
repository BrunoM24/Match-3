extends Node2D


export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset
export (int) var y_offset

# Obstacle props
export (PoolVector2Array) var empty_spaces
export (PoolVector2Array) var ice_spaces

# Obstacle Signals
signal make_ice
signal damage_ice

var pieces = []

var possible_pieces = [
	preload("res://src/pieces/BluePiece.tscn"),
	preload("res://src/pieces/GreenPiece.tscn"),
	preload("res://src/pieces/LightGreenPiece.tscn"),
	preload("res://src/pieces/OrangePiece.tscn"),
	preload("res://src/pieces/PinkPiece.tscn"),
	preload("res://src/pieces/YellowPiece.tscn")
]

var first_touch := Vector2.ZERO
var final_touch := Vector2.ZERO
var controlling := false

# State Machine
enum {wait, move}

var state

#swap back variables
var piece_one = null
var piece_two = null
var last_place := Vector2.ZERO
var last_direction := Vector2.ZERO
var move_checked = false


# Called when the node enters the scene tree for the first time.
func _ready():
	state = move
	randomize()
	pieces = make_2d_array()
	spawn_pieces()
	spawn_ice()


func _physics_process(delta):
	if state == move:
		touch_input()


func make_2d_array() -> Array:
	var array := []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array


func spawn_pieces() -> void:
	for col in width:
		for row in height:
			if restricted_fill(Vector2(col, row)):
				continue
			
			var piece = possible_pieces[randi() % possible_pieces.size() - 1].instance()
			
			while(match_at(col, row, piece.color)):
				piece = possible_pieces[randi() % possible_pieces.size() - 1].instance()
			
			piece.position = grid_to_pixel(col, row)
			add_child(piece)
			pieces[col][row] = piece


func spawn_ice() -> void:
	for ice in ice_spaces:
		emit_signal("make_ice", ice)


func match_at(column: int, row: int, color: String) -> bool:
	if column > 1:
		if pieces[column - 1][row] != null && pieces[column - 2][row] != null:
			if pieces[column - 1][row].color == color && pieces[column - 2][row].color == color:
				return true
				
	if row > 1:
		if pieces[column][row - 1] != null && pieces[column][row - 2] != null:
			if pieces[column][row - 1].color == color && pieces[column][row - 2].color == color:
				return true
	
	return false


func grid_to_pixel(column: int, row: int) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(mouse_position: Vector2) -> Vector2:
	var column = round((mouse_position.x - x_start) / offset)
	var row = round((mouse_position.y - y_start) / -offset)
	return Vector2(column, row)


func touch_input() -> void:
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position())):
			first_touch = pixel_to_grid(get_global_mouse_position())
			controlling = true
	
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position())) && controlling:
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position())
			touch_difference(first_touch, final_touch)


func is_in_grid(grid_position: Vector2) -> bool:
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	
	return false


func swap_pieces(column : int, row : int, direction: Vector2) -> void:
	var first_piece = pieces[column][row]
	var other_piece = pieces[column + direction.x][row + direction.y]
	
	if first_piece != null && other_piece != null:
		store_info(first_piece, other_piece, Vector2(column, row), direction)
		state = wait
		pieces[column][row] = other_piece
		pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		
		if not move_checked:
			find_matches()


func store_info(first_piece, other_piece, place: Vector2, direction: Vector2) -> void:
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


func swap_back() -> void:
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	
	state = move
	move_checked = false


func touch_difference(grid_1: Vector2, grid_2: Vector2) -> void:
	var difference := grid_2 - grid_1
	
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


func find_matches() -> void:
	for col in width:
		for row in height:
			if pieces[col][row] != null:
				var color = pieces[col][row].color
				
				if col > 0 && col < width - 1:
					if !is_piece_null(col - 1, row) && !is_piece_null(col + 1, row):
						if pieces[col - 1][row].color == color && pieces[col + 1][row].color == color:
							match_and_dim(pieces[col - 1][row])
							match_and_dim(pieces[col][row])
							match_and_dim(pieces[col + 1][row])
				
				if row > 0 && row < height - 1:
					if !is_piece_null(col, row - 1) && !is_piece_null(col, row + 1):
						if pieces[col][row - 1].color == color && pieces[col][row + 1].color == color:
							match_and_dim(pieces[col][row - 1])
							match_and_dim(pieces[col][row])
							match_and_dim(pieces[col][row + 1])
	
	get_parent().get_node("DestroyTimer").start()


func is_piece_null(col: int, row: int) -> bool:
	return pieces[col][row] == null


func match_and_dim(item) -> void:
	item.matched = true
	item.dim()


func destroy_matches() -> void:
	var was_matched = false
	
	for col in width:
		for row in height:
			if pieces[col][row] != null:
				if pieces[col][row].matched:
					emit_signal("damage_ice", Vector2(col, row))
					was_matched = true
					pieces[col][row].queue_free()
					pieces[col][row] = null
	
	move_checked = true
	if was_matched:
		get_parent().get_node("CollapseTimer").start()
	else:
		swap_back()


func collapse_collumns() -> void:
	for col in width:
		for row in height:
			if pieces[col][row] == null && not restricted_fill(Vector2(col, row)):
				for i in range(row + 1, height):
					if pieces[col][i] != null:
						pieces[col][i].move(grid_to_pixel(col, row))
						pieces[col][row] = pieces[col][i]
						pieces[col][i] = null
						break
	
	get_parent().get_node("RefillTimer").start()


func refill_collumns() -> void:
	for col in width:
		for row in height:
			if pieces[col][row] == null && not restricted_fill(Vector2(col, row)):
				var piece = possible_pieces[randi() % possible_pieces.size() - 1].instance()
				
				while(match_at(col, row, piece.color)):
					piece = possible_pieces[randi() % possible_pieces.size() - 1].instance()
				
				add_child(piece)
				piece.position = grid_to_pixel(col, row - y_offset)
				piece.move(grid_to_pixel(col, row))
				pieces[col][row] = piece
	
	after_refill()


func after_refill() -> void:
	for col in width:
		for row in height:
			if pieces[col][row] !=  null:
				if match_at(col, row, pieces[col][row].color):
					find_matches()
					get_parent().get_node("DestroyTimer").start()
					break
	
	state = move
	move_checked = false


func restricted_fill(place: Vector2) -> bool:
	#check the empty pieces
	return is_in_array(empty_spaces, place)


func is_in_array(array: Array, item) -> bool:
	for i in array.size():
		if array[i] == item:
			return true
	
	return false


func _on_DestroyTimer_timeout():
	destroy_matches()


func _on_CollapseTimer_timeout():
	collapse_collumns()


func _on_RefillTimer_timeout():
	refill_collumns()

