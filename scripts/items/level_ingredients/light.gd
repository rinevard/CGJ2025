class_name Light extends Item
@onready var attract_area: NoiseArea = $AttractArea
@onready var normal_noise_area: NoiseArea = $NormalNoiseArea

enum States {
	NORMAL,
	ATTRACTING
}
var state: States = States.NORMAL
var time_in_cur_state: float = 0.0

func _process(delta: float) -> void:	
	time_in_cur_state += delta
	match state:
		States.ATTRACTING:
			_enter_state(States.NORMAL)

@onready var point_light_2d: PointLight2D = $PointLight2D
func activate() -> void:
	match state:
		States.NORMAL:
			_enter_state(States.ATTRACTING)
			# 改变灯光
			point_light_2d.enabled = not point_light_2d.enabled
			attract_area.make_noise()
			
func _enter_state(new_state: States):
	state = new_state
	time_in_cur_state = 0.0
