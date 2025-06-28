# npc.gd 的 _explode_soul_point 会创建新 soul_point
class_name SoulPoint extends Node2D

func die():
	call_deferred("queue_free")

const SOUL_POINT = preload("res://scenes/npcs/soul_point.tscn")
static func new_soul_point() -> SoulPoint:
	var point = SOUL_POINT.instantiate()
	return point
