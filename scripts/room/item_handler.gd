class_name ItemHandler extends Node2D

@export var npc: NPC
var items: Array[Item] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children := get_children()
	for child in children:
		if child is Item:
			items.append(child)

# 每若干秒找到 npc 随机物品发 normal noise
const NORMAL_NOISE_FREQ = 3.0
var normal_noise_cooling_time: float = NORMAL_NOISE_FREQ
func _process(delta: float) -> void:
	normal_noise_cooling_time -= delta
	if normal_noise_cooling_time < NORMAL_NOISE_FREQ:
		normal_noise_cooling_time = NORMAL_NOISE_FREQ
		if npc.state == npc.States.IDLE:
			var item: Item = items.pick_random()
			item.make_normal_noise()
