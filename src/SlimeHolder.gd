extends Node2D


signal remove_slime

var slime_pieces = []
var width := 8
var height := 10

var slime_piece = preload("res://src/obstacles/Slime.tscn")


func _init():
	slime_pieces = make_2d_array()


func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array


func _on_Grid_make_slime(board_position: Vector2):
	var slime = slime_piece.instance()
	slime.position = Vector2(board_position.x * 64 + 64, board_position.y * -64 + 800)
	add_child(slime)
	slime_pieces[board_position.x][board_position.y] = slime


func _on_Grid_damage_slime(board_position: Vector2):
	var slime = slime_pieces[board_position.x][board_position.y]
	if slime != null:
		slime.take_damage(1)
		if slime.health <= 0:
			slime.queue_free()
			slime_pieces[board_position.x][board_position.y] = null
			emit_signal("remove_slime", board_position)
