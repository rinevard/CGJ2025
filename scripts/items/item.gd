class_name Item extends Node2D

@onready var normal_noise_area: NoiseArea = $NormalNoiseArea
@onready var attract_noise_area: NoiseArea = $AttractNoiseArea
@onready var scare_noise_area: NoiseArea = $ScareNoiseArea

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("key_n"):
		normal_noise_area.open_area()
	elif event.is_action_pressed("key_a"):
		print("attract acitve")
		attract_noise_area.open_area()
	elif event.is_action_pressed("key_s"):
		scare_noise_area.open_area()
	else:
		normal_noise_area.close_area()
		attract_noise_area.close_area()
		scare_noise_area.close_area()
	if event.is_action_pressed("left"):
		global_position.x -= 32.0
	elif event.is_action_pressed("right"):
		global_position.x += 32.0
