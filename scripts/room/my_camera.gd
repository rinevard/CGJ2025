extends Camera2D

@export var follow_character: CharacterBody2D

## 相机跟随的平滑度。数值越小，相机移动越“滞后”；数值越大，跟随越紧密。
@export var smoothing_speed: float = 5.0
@export var room_width: float = 2880.0

var window_size

var _shake_duration: float = 0.0 # 震动剩余持续时间
var _shake_amplitude: float = 0.0 # 震动初始幅度/强度
var _initial_shake_duration: float = 0.0 # 用于计算衰减比例

func _ready() -> void:
	SignalHandler.need_shake_screen.connect(screen_shake)
	window_size = get_viewport().get_visible_rect().size
	global_position.x = clamp(global_position.x, window_size.x / 2, room_width - window_size.x / 2)
	global_position.y = window_size.y / 2

func _physics_process(delta: float) -> void:
	if follow_character:
		var target_position = follow_character.global_position
		target_position.x = clamp(target_position.x, window_size.x / 2, room_width - window_size.x / 2)
		target_position.y = window_size.y / 2
		global_position = lerp(global_position, target_position, smoothing_speed * delta)
	else:
		push_error("Camera's follower is not set!")

	if _shake_duration > 0:
		_shake_duration -= delta
		
		# 计算震动衰减
		var decay_factor = ease(_shake_duration / _initial_shake_duration, Tween.EASE_OUT)
		var current_amplitude = _shake_amplitude * decay_factor
		
		# 这样可以在随机方向上震动
		var random_offset = Vector2.from_angle(randf_range(0, TAU)) * current_amplitude
		
		offset = random_offset
		
		if _shake_duration <= 0:
			offset = Vector2.ZERO
	
func screen_shake(amplitude: float = 10.0, duration: float = 0.2) -> void:
	_shake_amplitude = amplitude
	_shake_duration = duration
	_initial_shake_duration = duration
