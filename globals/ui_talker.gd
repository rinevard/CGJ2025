extends Node

var soul_power: int = 0

var fps: float = 30.0
func _process(delta: float) -> void:
	fps = Engine.get_frames_per_second()
	# print(fps) # 秘密武器, 提高帧数
