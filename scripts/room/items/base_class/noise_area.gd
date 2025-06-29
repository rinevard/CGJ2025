## Item 会被 ghost 附身, ghost 会调用 item 的 activate 方法来 "发出讯息" 吸引 NPC
## 这里的 NoiseArea 就是讯息, 它有一定的持续时间(noise_duration), 在持续时间后不再吸引 NPC
class_name NoiseArea extends Area2D

@export var noise_type: Observation.ObservationType = Observation.ObservationType.NORMAL

func _ready() -> void:
	close_area()

func get_obs() -> Observation:
	var parent = get_parent()
	if parent is Item:
		var obs = Observation.new_obs(noise_type, parent.global_position, parent)
		return obs
	return null

## 在持续时间后不再吸引 NPC
@export var noise_duration: float = 0.1
func make_noise() -> void:
	open_area()
	await get_tree().create_timer(noise_duration).timeout
	close_area()

func open_area() -> void:
	call_deferred("set_collision_layer_value", 1, true)
	
func close_area() -> void:
	call_deferred("set_collision_layer_value", 1, false)
