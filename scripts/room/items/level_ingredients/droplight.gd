class_name DropLight extends Item
@onready var attract_area: NoiseArea = $AttractArea

enum States {
	NORMAL,
	ATTRACTING
}
var state: States = States.NORMAL

## 吸引状态持续时间, 这是不是和 noise_area 的 duration 功能重复了?
@export var time_attracting: float = 0.1
var time_in_cur_state: float = 0.0

func _process(delta: float) -> void:
	time_in_cur_state += delta
	match state:
		States.ATTRACTING:
			if time_in_cur_state > time_attracting:
				_enter_state(States.NORMAL)

@onready var point_light_2d_max: PointLight2D = $PointLight2D_max
@onready var point_light_2d_mid: PointLight2D = $PointLight2D_mid
@onready var point_light_2d_min: PointLight2D = $PointLight2D_min
var enabled = true
func activate() -> void:
	match state:
		States.NORMAL:
			_enter_state(States.ATTRACTING)
			enabled = not enabled
			point_light_2d_max.enabled = enabled
			point_light_2d_mid.enabled = enabled
			point_light_2d_min.enabled = enabled
			attract_area.make_noise()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _enter_state(new_state: States):
	if new_state == States.NORMAL:
		# 切换灯状态
		animated_sprite_2d.frame = (animated_sprite_2d.frame + 1) % 2
	state = new_state
	time_in_cur_state = 0.0
