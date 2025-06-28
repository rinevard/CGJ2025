class_name Door extends Item

@onready var scare_area: NoiseArea = $ScareArea

enum States {
	NORMAL,
	SCARING
}
var state: States = States.NORMAL
## 惊吓状态持续时间
var time_in_cur_state: float = 0.0

func _process(delta: float) -> void:
	time_in_cur_state += delta
	match state:
		States.SCARING:
			# 门的惊吓是在开关时瞬间的, 因此没有 time_scaring
			_enter_state(States.NORMAL)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func activate() -> void:
	match state:
		States.NORMAL:
			# 开门
			if animated_sprite_2d.frame == 0:
				SfXPlayer.play_sfx(SfXPlayer.SFXs.DOOR_CREAK, global_position)
			else:
				SfXPlayer.play_sfx(SfXPlayer.SFXs.DOOR_SLAM, global_position)
			animated_sprite_2d.frame = (1 + animated_sprite_2d.frame) % 2
			_enter_state(States.SCARING)
			scare_area.make_noise()

func _enter_state(new_state: States):
	state = new_state
	time_in_cur_state = 0.0
