class_name NoiseArea extends Area2D

@export var noise_type: Observation.ObservationType = Observation.ObservationType.NORMAL

func get_obs() -> Observation:
	var parent = get_parent()
	if parent is Item:
		var obs = Observation.new_obs(noise_type, parent.global_position, parent)
	return null
