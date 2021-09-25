extends Node2D


signal remove_lock

var lock_pieces = []
var width := 8
var height := 10

var lock_lock = preload("res://src/obstacles/Licorice.tscn")


func _init():
	lock_pieces = make_2d_array()


func make_2d_array() -> Array:
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	
	return array


func _on_Grid_make_lock(board_position: Vector2):
	var lock = lock_lock.instance()
	lock.position = Vector2(board_position.x * 64 + 64, board_position.y * -64 + 800)
	add_child(lock)
	lock_pieces[board_position.x][board_position.y] = lock


func _on_Grid_damage_lock(board_position: Vector2):
	var lock = lock_pieces[board_position.x][board_position.y]
	if lock != null:
		lock.take_damage(1)
		if lock.health <= 0:
			lock.queue_free()
			lock_pieces[board_position.x][board_position.y] = null
			emit_signal("remove_lock", board_position)

