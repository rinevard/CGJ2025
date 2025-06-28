class_name ItemHandler extends Node2D

@export var npc: NPC
var items: Array[Item] = []

func _ready() -> void:
	var children := get_children()
	for child in children:
		if child is Item:
			items.append(child)

# 每若干秒找随机物品发 normal noise 吸引 NPC
const NORMAL_NOISE_FREQ = 5.0
var normal_noise_cooling_time: float = NORMAL_NOISE_FREQ
func _process(delta: float) -> void:
	normal_noise_cooling_time -= delta
	if normal_noise_cooling_time < NORMAL_NOISE_FREQ:
		normal_noise_cooling_time = NORMAL_NOISE_FREQ
		if npc.state == npc.States.IDLE:
			var item: Item = items.pick_random()
			item.make_normal_noise()
