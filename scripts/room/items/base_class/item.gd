## Item 会被 ghost 附身, ghost 会调用 item 的 activate 方法来 "发出讯息" 吸引 NPC
## 讯息是一个 Area2D, NPC 的 observer 会注意到信息并更新自身的 observation, 
## NPC 会根据自己的 observation 更新动作
class_name Item extends Node2D

# 移动该物品时最多移动这么多距离
@export var min_x_bias: float = -99999.0
@export var max_x_bias: float = 99999.0
var cur_bias: float = 0.0

@export var move_speed: float = 140.0
var smoothing_speed: float = 0.8
## 当附身时每帧都调用
func move(dir_x: float, delta: float):
	var new_bias: float = cur_bias + move_speed * dir_x * delta
	new_bias = clamp(new_bias, min_x_bias, max_x_bias)
	var target_global_x = global_position.x + (new_bias - cur_bias)
	global_position.x = target_global_x
	cur_bias = new_bias
	if dir_x != 0:
		# 如果移动了, 发出震动信号
		SignalHandler.need_shake_screen.emit(0.8, 0.2)

func activate() -> void:
	pass

## 发出讯息吸引NPC, 模拟 "NPC在没有被鬼吸引的时候主动前往某地"
func make_normal_noise() -> void:
	$NormalNoiseArea.make_noise()
