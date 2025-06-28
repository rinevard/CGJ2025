class_name Television extends Item

@onready var attract_area: NoiseArea = $AttractArea
@onready var scare_area: NoiseArea = $ScareArea
@onready var normal_noise_area: NoiseArea = $NormalNoiseArea

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
	match new_state:
		States.NORMAL:
			$Sprite2D.modulate.r = 1.0
			$Sprite2D.modulate.g = 1.0
		States.ATTRACTING:
			$Sprite2D.modulate.r = 0.5
			$Sprite2D.modulate.g = 0.5
		States.SCARING:
			$Sprite2D.modulate.r = 0.0
			$Sprite2D.modulate.g = 0.0
	state = new_state
	time_in_cur_state = 0.0
