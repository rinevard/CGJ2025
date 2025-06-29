extends Room

# 我们只需要引用 ParallaxBackground 就够了
@onready var parallax_background: ParallaxBackground = $ParallaxBackground

# 导出这个变量，你可以在编辑器里随时调整速度！
@export var scroll_speed: float = 500.0

func _process(delta: float):
	# 只需要修改这一个属性，所有层都会根据自己的速度自动滚动！
	parallax_background.scroll_offset.x -= scroll_speed * delta
