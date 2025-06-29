class_name Phone extends Item
@onready var attract_area: NoiseArea = $AttractArea
@onready var normal_noise_area: NoiseArea = $NormalNoiseArea

enum States {
	NORMAL,
	ATTRACTING
}
var state: States = States.NORMAL
## 吸引状态持续时间
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
			SfXPlayer.play_sfx(SfXPlayer.SFXs.PHONE_RING, global_position)
			_enter_state(States.ATTRACTING)
			attract_area.make_noise()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _enter_state(new_state: States):
	if new_state == States.NORMAL:
		animated_sprite_2d.play("normal")
	elif new_state == States.ATTRACTING:
		animated_sprite_2d.play("ring")
	state = new_state
	time_in_cur_state = 0.0
