extends TextureRect

func _ready() -> void:
	self.modulate.a = 1.0
func _process(delta: float) -> void:
	self.modulate.a = lerp(self.modulate.a, 0.0, delta * 4.0)
