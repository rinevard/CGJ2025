extends Sprite2D

@export var bpm = 100
# 手绘窗口描边效果
# 为了让描边随着音乐变化所以做了按bpm设置frame的设计
var time = 0.0
func _process(delta: float) -> void:
    time += delta
    frame = int(time * bpm / 60.0) % hframes