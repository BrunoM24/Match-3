extends Node2D


signal remove_concrete

var concrete_pieces = []
var width := 8
var height := 10

var concrete_piece = preload("res://src/obstacles/Concrete.tscn")


func _init():
	concrete_pieces = make_2d_array()


func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array


func _on_Grid_make_concrete(board_position: Vector2):
	var concrete = concrete_piece.instance()
	concrete.position = Vector2(board_position.x * 64 + 64, board_position.y * -64 + 800)
	add_child(concrete)
	concrete_pieces[board_position.x][board_position.y] = concrete


func _on_Grid_damage_concrete(board_position: Vector2):
	var concrete = concrete_pieces[board_position.x][board_position.y]
	if concrete != null:
		concrete.take_damage(1)
		if concrete.health <= 0:
			concrete.queue_free()
			concrete_pieces[board_position.x][board_position.y] = null
			emit_signal("remove_concrete", board_position)

