class_name ItemHandler extends Node2D

@export var npc: NPC
var items: Array[Item] = []

func _ready() -> void:
	var children := get_children()
	for child in children:
		if child is Item:
			items.append(child)

# 每若干秒找随机物品发 normal noise 吸引 NPC
const NORMAL_NOISE_FREQ = 3.0
var normal_noise_cooling_time: float = 0.0 # 开局先发一次
func _process(delta: float) -> void:
	normal_noise_cooling_time -= delta
	if normal_noise_cooling_time < 0.0:
		normal_noise_cooling_time = NORMAL_NOISE_FREQ
		if npc.state == npc.States.IDLE:
			var item: Item = items.pick_random()
			item.make_normal_noise()
			print("Handler make noise")
