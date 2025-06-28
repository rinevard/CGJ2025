class_name ScareItem extends Node2D

@onready var scare_area: NoiseArea = $ScareArea

enum States {
	NORMAL,
	SCARING
}
var state: States = States.NORMAL
## 惊吓状态持续时间
@export var time_scaring: float = 5.0
var time_in_cur_state: float = 0.0

func _process(delta: float) -> void:
	time_in_cur_state += delta
	match state:
		States.SCARING:
			if time_in_cur_state > time_scaring:
				_enter_state(States.NORMAL)

func activate() -> void:
	match state:
		States.NORMAL:
			_enter_state(States.SCARING)
			scare_area.make_noise()
			
func _enter_state(new_state: States):
	state = new_state
	time_in_cur_state = 0.0
