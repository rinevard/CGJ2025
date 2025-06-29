extends Label

var time = 0.0
var y0

func _ready() -> void:
    y0 = position.y

func _process(delta: float) -> void:
    time += delta
    modulate.a = 0.8 + 0.2 * sin(time * 2.0)
    position.y = y0 + 10.0 * sin(time * 1.7)