extends Item

@onready var attract_area: NoiseArea = $AttractArea
@onready var scare_area: NoiseArea = $ScareArea

enum States {
	NORMAL,
	ATTRACTING,
	SCARING
}
var state: States = States.NORMAL
@export var time_attracting: float = 10.0
@export var time_scaring: float = 3.0
var time_in_cur_state: float = 0.0

func _process(delta: float) -> void:
	time_in_cur_state += delta
	match state:
		States.ATTRACTING:
			if time_in_cur_state > time_attracting:
				_enter_state(States.NORMAL)
		States.SCARING:
			if time_in_cur_state > time_scaring:
				_enter_state(States.NORMAL)

func activate() -> void:
	match state:
		States.NORMAL:
			_enter_state(States.ATTRACTING)
			attract_area.make_noise()
		States.ATTRACTING:
			_enter_state(States.SCARING)
			scare_area.make_noise()
			
func _enter_state(new_state: States):
	state = new_state
	time_in_cur_state = 0.0
