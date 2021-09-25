extends Node2D


var ice_pieces = []
var width := 8
var height := 10

var ice_piece = preload("res://src/obstacles/Ice.tscn")


func _init():
	ice_pieces = make_2d_array()


func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array


func _on_Grid_make_ice(board_position: Vector2):
	var ice = ice_piece.instance()
	ice.position = Vector2(board_position.x * 64 + 64, board_position.y * -64 + 800)
	add_child(ice)
	ice_pieces[board_position.x][board_position.y] = ice


func _on_Grid_damage_ice(board_position: Vector2):
	var piece = ice_pieces[board_position.x][board_position.y]
	if piece != null:
		piece.take_damage(1)
		if piece.health <= 0:
			piece.queue_free()
			ice_pieces[board_position.x][board_position.y] = null

