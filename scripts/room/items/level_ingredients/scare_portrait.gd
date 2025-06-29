class_name ScarePortrait extends Item

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

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func activate() -> void:
	match state:
		States.NORMAL:
			SfXPlayer.play_sfx(SfXPlayer.SFXs.PORTRAIT_ROLL, global_position)
			_enter_state(States.SCARING)
			scare_area.make_noise()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
func _enter_state(new_state: States):
	if new_state == States.SCARING:
		animation_player.play("scare")
	state = new_state
	time_in_cur_state = 0.0
