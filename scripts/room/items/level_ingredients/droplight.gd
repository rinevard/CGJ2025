class_name DropLight extends Item
@onready var attract_area: NoiseArea = $AttractArea

enum States {
	NORMAL,
	ATTRACTING
}
var state: States = States.NORMAL

## 吸引状态持续时间, 这是不是和 noise_area 的 duration 功能重复了?
@export var time_attracting: float = 10.0
var time_in_cur_state: float = 0.0

func _process(delta: float) -> void:
	time_in_cur_state += delta
	match state:
		States.ATTRACTING:
			if time_in_cur_state > time_attracting:
				_enter_state(States.NORMAL)

func activate() -> void:
	match state:
		States.NORMAL:
			_enter_state(States.ATTRACTING)
			attract_area.make_noise()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _enter_state(new_state: States):
	if new_state == States.NORMAL:
		# 开灯
		animated_sprite_2d.frame = 0
	else:
		animated_sprite_2d.frame = 1
	state = new_state
	time_in_cur_state = 0.0
