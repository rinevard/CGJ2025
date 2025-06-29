## Item 会被 ghost 附身, ghost 会调用 item 的 activate 方法来 "发出讯息" 吸引 NPC
## 讯息是一个 Area2D, NPC 的 observer 会注意到信息并更新自身的 observation, 
## NPC 会根据自己的 observation 更新动作
class_name Item extends Node2D

func activate() -> void:
	pass

## 发出讯息吸引NPC, 模拟 "NPC在没有被鬼吸引的时候主动前往某地"
func make_normal_noise() -> void:
	$NormalNoiseArea.make_noise()
