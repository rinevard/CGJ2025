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
@export var time_attracting: float = 4.8
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
			SfXPlayer.play_sfx(SfXPlayer.SFXs.TV_STATIC_LOOP, global_position)
			_enter_state(States.ATTRACTING)
			attract_area.make_noise()
		States.ATTRACTING:
			_enter_state(States.SCARING)
			scare_area.make_noise()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _enter_state(new_state: States):
	match new_state:
		States.NORMAL:
			animated_sprite_2d.play("off")
		States.ATTRACTING:
			animated_sprite_2d.play("snow")
		States.SCARING:
			animated_sprite_2d.play("scare")
	state = new_state
	time_in_cur_state = 0.0
