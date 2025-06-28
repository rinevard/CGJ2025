class_name NPC extends CharacterBody2D
@onready var ai: AI = $AI

var run_speed: float = 200.0
var walk_speed: float = 100.0

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
const time_scare_to_run: float = 1.0
const time_run_to_idle: float = 3.0
const time_confuse_to_idle: float = 1.0
var cur_time_in_state: float = 0.0
#endregion

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
			velocity = Vector2.ZERO
			# TODO 放个 scare 动画
			if cur_time_in_state > time_scare_to_run:
				_enter_state(States.RUN)
		States.RUN:
			if action == Actions.LEFT:
				velocity.x = -run_speed
			elif action == Actions.RIGHT:
				velocity.x = run_speed
			
			if cur_time_in_state > time_run_to_idle:
				_enter_state(States.IDLE)
		States.CONFUSE:
			velocity = Vector2.ZERO
			if action == Actions.SCARE:
				_enter_state(States.SCARE)
			elif cur_time_in_state > time_confuse_to_idle:
				_enter_state(States.IDLE)
		States.IDLE:
			velocity = Vector2.ZERO
			# TODO 放闲置动画
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
			match action:
				Actions.SCARE:
					_enter_state(States.SCARE)
				Actions.CONFUSE:
					_enter_state(States.CONFUSE)
				Actions.IDLE:				
					_enter_state(States.IDLE)
				Actions.LEFT:
					velocity.x = -walk_speed
				Actions.RIGHT:
					velocity.x = walk_speed
	
	move_and_slide()
	_update_label_text()

func _enter_state(new_state: States):
	cur_time_in_state = 0.0
	state = new_state
	print("new_state: ", state_str[new_state])

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
		debug_label.text = "npc state: " + state_str[state]
