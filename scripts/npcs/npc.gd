class_name NPC extends CharacterBody2D
@onready var ai: AI = $AI
@onready var audio_footstep_normal: AudioStreamPlayer2D = $AudioFootstepNormal
@onready var audio_footstep_fast: AudioStreamPlayer2D = $AudioFootstepFast
@onready var audio_confuse: AudioStreamPlayer2D = $AudioConfuse
@onready var audio_scream: AudioStreamPlayer2D = $AudioScream

var run_speed: float = 400.0
var walk_speed: float = 200.0

enum Actions {
	IDLE,
	LEFT,
	RIGHT,
	CONFUSE,
	SCARE,
	SPECIAL_LEFTRUN
}

#region 状态机相关
enum States {
	SCARE,
	RUN,
	CONFUSE,
	IDLE,
	WALK,
}
var state: States = States.IDLE
const time_scare_to_run: float = 1.0 # SCARE 若干秒后转入 RUN 态
var time_run_to_idle: float = 3.0 # RUN 若干秒后转入 IDLE 态
const time_confuse_to_idle: float = 1.0 # CONFUSE 若干秒后转入 IDLE 态
var cur_time_in_state: float = 0.0
#endregion

#region 心率相关
const MAX_HEART_RATE = 200
const MIN_HEART_RATE = 60

# 目标心率(target), 变化速度(change_speed), UI波动范围(fluctuation)
const HEART_RATE_PROFILES = {
	States.IDLE: {"target": 65.0, "change_speed": 0.5, "fluctuation": 5.0},
	States.WALK: {"target": 95.0, "change_speed": 1.0, "fluctuation": 8.0},
	States.CONFUSE: {"target": 130.0, "change_speed": 1.2, "fluctuation": 12.0},
	States.RUN: {"target": 160.0, "change_speed": 1.8, "fluctuation": 10.0},
	States.SCARE: {"target": 180.0, "change_speed": 0.8, "fluctuation": 15.0}
}

var _current_heart_rate: float = 65.0
const SCARE_SPIKE_AMOUNT: float = 60.0 # 受到惊吓时，心率瞬间增加的值
#endregion


func _ready() -> void:
	# 这个耦合很糟糕, 恐惧时间 + 跑时间 = 总惊吓时间
	# (不过我们已经到处都是耦合了不是吗)
	time_run_to_idle = $AI/Actor.SCARE_TIME - time_scare_to_run
	_init_heartrate()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
func _physics_process(delta: float) -> void:
	var action: Actions = ai.get_action(delta)
	cur_time_in_state += delta
	# SCARE 若干秒后转入 RUN 态
	# RUN 若干秒后转入 IDLE 态
	# CONFUSE 若干秒后转入 IDLE 态
	# IDLE, WALK, CONFUSE 受到 SCARE 动作转入 SCARE 态
	# IDLE 和 WALK 受到 CONFUSE 动作转入 CONFUSE 态
	# IDLE 和 WALK 可以相互转化
	match state:
		States.SCARE:
			_flip_sprite(_is_target_left_dir())
			animation_player.play("scare")
			velocity = Vector2.ZERO
			# TODO 放个 scare 动画
			if cur_time_in_state > time_scare_to_run:
				_enter_state(States.RUN)
		States.RUN:
			animation_player.play("run")
			if action == Actions.LEFT:
				velocity.x = - run_speed
			elif action == Actions.RIGHT:
				velocity.x = run_speed
			
			if cur_time_in_state > time_run_to_idle:
				_enter_state(States.IDLE)
				#_explode_soul_point()
		States.CONFUSE:
			_flip_sprite(_is_target_left_dir())
			animation_player.play("confuse")
			velocity = Vector2.ZERO
			if action == Actions.SCARE:
				_enter_state(States.SCARE)
			elif cur_time_in_state > time_confuse_to_idle:
				_enter_state(States.IDLE)
		States.IDLE:
			_flip_sprite(_is_target_left_dir())
			animation_player.play("idle")
			velocity = Vector2.ZERO
			match action:
				Actions.SCARE:
					_enter_state(States.SCARE)
				Actions.CONFUSE:
					_enter_state(States.CONFUSE)
				Actions.LEFT:
					_enter_state(States.WALK)
				Actions.RIGHT:
					_enter_state(States.WALK)
		States.WALK:
			animation_player.play("walk")
			match action:
				Actions.SCARE:
					_enter_state(States.SCARE)
				Actions.CONFUSE:
					_enter_state(States.CONFUSE)
				Actions.IDLE:
					_enter_state(States.IDLE)
				Actions.LEFT:
					velocity.x = - walk_speed
				Actions.RIGHT:
					velocity.x = walk_speed
	
	_update_heartrate(delta)
	_flip_if_needed()
	move_and_slide()
	_update_label_text()

# 用一个糟糕的 hack 拿到目标 item
func _is_target_left_dir() -> bool:
	var obs: Observation = $AI/Observer.get_last_observation()
	if not obs:
		return false
	return obs.global_pos.x <= global_position.x

var flip_duration: float = 0.14
var is_flipping: bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _flip_sprite(is_face_left: bool):
	# 判断精灵是否应该被翻转 (朝左时应当翻转)
	var should_be_flipped: bool = is_face_left
	if animated_sprite_2d.flip_h != should_be_flipped:
		is_flipping = true
		var abs_scale_x: float = abs(animated_sprite_2d.scale.x)

		var tween = create_tween()
		tween.set_parallel(false)
	
		tween.tween_property(animated_sprite_2d, "scale:x", 0.0, flip_duration / 2.0)
		# 在动画中途，更新 flip_h 属性
		tween.tween_callback(func(): animated_sprite_2d.flip_h = should_be_flipped)
		tween.tween_property(animated_sprite_2d, "scale:x", abs_scale_x, flip_duration / 2.0)
		
		# 第四步：动画完成后，重置状态
		tween.finished.connect(func(): is_flipping = false)

func _flip_if_needed() -> void:
	# 如果正在翻转，或者水平速度为0，则不执行任何操作
	if is_flipping or velocity.x == 0:
		return
	_flip_sprite(velocity.x < 0)

#region 心率函数
func _init_heartrate() -> void:
	_current_heart_rate = HEART_RATE_PROFILES[States.IDLE].target
	var initial_profile = HEART_RATE_PROFILES[States.IDLE]
	UITalker.heart_beat_lower = roundi(_current_heart_rate - initial_profile.fluctuation / 2.0)
	UITalker.heart_beat_upper = roundi(_current_heart_rate + initial_profile.fluctuation / 2.0)

func _update_heartrate(delta: float) -> void:
	# A. 获取当前状态的心率档案
	var profile = HEART_RATE_PROFILES[state]
	var target_rate = profile.target
	var change_speed = profile.change_speed
	var fluctuation = profile.fluctuation
	
	# B. 使用lerp让真实心率值平滑地趋近目标值
	_current_heart_rate = lerp(
		_current_heart_rate,
		target_rate,
		change_speed * delta
	)
	
	# C. 基于当前的真实心率，计算出给UI显示的波动范围
	var lower_bound = _current_heart_rate - fluctuation / 2.0
	var upper_bound = _current_heart_rate + fluctuation / 2.0
	
	# D. 更新到UI（使用roundi更清晰地表示四舍五入到整数）
	UITalker.heart_beat_lower = roundi(lower_bound)
	UITalker.heart_beat_upper = roundi(upper_bound)

## 处理瞬时心率冲击的函数
func _trigger_heart_rate_spike() -> void:
	print("Heart rate spike triggered!")
	_current_heart_rate += SCARE_SPIKE_AMOUNT
	_current_heart_rate = clampf(_current_heart_rate, MIN_HEART_RATE, MAX_HEART_RATE)
#endregion

func _enter_state(new_state: States):
	cur_time_in_state = 0.0
	if state != new_state:
		audio_footstep_fast.stop()
		audio_footstep_normal.stop()
		audio_confuse.stop()
		audio_scream.stop()
		match new_state:
			States.SCARE:
				audio_scream.play()
			States.RUN:
				audio_footstep_fast.play()
			States.CONFUSE:
				audio_confuse.play()
			States.WALK:
				audio_footstep_normal.play()

	state = new_state
	print("new_state: ", state_str[new_state])
	# 如果是从非惊吓状态进入惊吓状态，立即触发心率尖峰
	if new_state == States.SCARE and state != States.SCARE:
		_trigger_heart_rate_spike()

@export var debug_label: Label
var state_str: Array[String] = [
	"scare",
	"run",
	"confuse",
	"idle",
	"walk",
	"unknown",
	"unknown"
]
func _update_label_text() -> void:
	if debug_label:
		debug_label.text = "npc state: " + state_str[state] + "\nheart_beat_lower: " + str(UITalker.heart_beat_lower) + "\nheart_beat_upper: " + str(UITalker.heart_beat_upper)

func _explode_soul_point() -> void:
	var soul_point = SoulPoint.new_soul_point()
	soul_point.global_position = global_position
	get_parent().add_child(soul_point)
	print("爆装备")
