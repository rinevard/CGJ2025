class_name Item extends Node2D

var normal_noise_possib: float = 0.1
func activate() -> void:
	pass

func make_normal_noise() -> void:
	$NormalNoiseArea.make_noise()
