class_name RoomHandler extends Node2D

const ROOM_1 = preload("res://scenes/room/room1.tscn")
const ROOM_2 = preload("res://scenes/room/room2.tscn")
const ROOM_3 = preload("res://scenes/room/room3.tscn")
const ROOM_4 = preload("res://scenes/room/room4.tscn")

@export var cur_room: Room

var rooms: Array = [
	ROOM_1,
	ROOM_2,
	ROOM_3,
	ROOM_4
]

func change_room(new_room_num: int) -> void:
	if new_room_num > rooms.size():
		# 也可能是结局?
		return
	var new_room = rooms[new_room_num].instantiate()
	cur_room.call_deferred("queue_free")
	add_child(new_room)
	cur_room = new_room
