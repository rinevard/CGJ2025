extends Node2D

# 聚光灯脚本，在玩家/NPC 头上用聚光灯增强场景光源效果
@export var constraint_y: float = -100.0
@export var following_object: Node2D = null
@export var smoothing_speed: float = 6.0

var target_x: float = 0.0
func _ready() -> void:
	if not following_object:
		push_error("Spotlight's following object is not setted!")
		return
	# 设置聚光灯的初始位置
	position.x = following_object.position.x
	position.y = constraint_y

func _process(delta: float) -> void:
	target_x = following_object.position.x
	position.x = lerp(position.x, target_x, smoothing_speed * delta)
