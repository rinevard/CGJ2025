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

@export var attract_time: float = 0.1
func make_noise() -> void:
	open_area()
	await get_tree().create_timer(attract_time).timeout
	close_area()

func open_area() -> void:
	call_deferred("set_collision_layer_value", 1, true)
	
func close_area() -> void:
	call_deferred("set_collision_layer_value", 1, false)
