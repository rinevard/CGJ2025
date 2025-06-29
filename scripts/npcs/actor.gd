## 根据 observations 返回动作
class_name Actor extends Node2D

#region Actor状态机
# actor 在不同 state 下对相同的观测有不同行为
enum ActorStates {
	NORMAL, # 前往一般观测的位置, 根据新观测转入 confused 或 scared
	SCARED, # 输出左右跑, 若干秒后转入 NORMAL
	FINAL_SCARED
}
# 当前状态
var cur_state: ActorStates = ActorStates.NORMAL
#endregion

# 当前目标
var cur_target: Observation = null
# 在有当前目标时, 如果目标更新, 把原目标记录下来
var memory_target: Observation = null

# 距离多近时认为已经到达了观测点
const obs_max_bias = 100.0
signal obs_entered(obs: Observation)
signal scare_ended()

# 被吓到时处在 SCARED 态的时间
const SCARE_TIME = 4.0

var time_in_cur_state: float = 0.0

## 根据观测返回动作
func get_action(last_observation: Observation, delta: float) -> NPC.Actions:
	time_in_cur_state += delta
	match cur_state:
		# 恐惧状态下只输出左右跑, 若干秒后转入 NORMAL
		ActorStates.SCARED:
			if time_in_cur_state >= SCARE_TIME:
				_change_state(ActorStates.NORMAL)
				cur_target = null
				memory_target = null
				scare_ended.emit()
			# 反方向跑
			if cur_target:
				if global_position.x > cur_target.global_pos.x:
					return NPC.Actions.RIGHT
				return NPC.Actions.LEFT
		# 终极惊吓状态下只往左跑
		ActorStates.FINAL_SCARED:
			# 跑路咯
			return NPC.Actions.SPECIAL_LEFTRUN
		# 如果最新观测的优先级更高, 更新观测并视情况返回动作
		ActorStates.NORMAL:
			var new_obs_getted: bool = false
			# 无目标时, 获取新观测为目标
			if cur_target == null and last_observation != null:
				memory_target = cur_target
				cur_target = last_observation
				new_obs_getted = true
			# 有目标时, 取优先级更高的观测作为目标
			# 同级时, 普通观测不改变目标, 别的改变目标
			elif last_observation and cur_target \
			and not Observation.is_equal(last_observation, cur_target) \
			 and (last_observation.priori > cur_target.priori \
			 or (last_observation.priori == cur_target.priori and \
			 	last_observation.priori != 0)):
				memory_target = cur_target
				cur_target = last_observation
				new_obs_getted = true
			# 无目标时, 且无新观测时, 取记忆作为目标
			elif cur_target == null:
				cur_target = memory_target
			
			# 根据当前目标返回动作
			if cur_target != null:
				match cur_target.typ:
					# 普通观测向目标走去, 走到了消除观测
					Observation.ObservationType.NORMAL:
						if abs(global_position.x - cur_target.global_pos.x) < obs_max_bias:
							obs_entered.emit(cur_target)
							cur_target = null
						elif global_position.x < cur_target.global_pos.x:
							return NPC.Actions.RIGHT
						else:
							return NPC.Actions.LEFT
					# 吸引观测向目标走去, 走到了消除观测
					Observation.ObservationType.ATTRACTION:
						# 对新 attractor, confuse一下再走过去
						if new_obs_getted:
							return NPC.Actions.CONFUSE
						if abs(global_position.x - cur_target.global_pos.x) < obs_max_bias:
							obs_entered.emit(cur_target)
							cur_target = null
						elif global_position.x < cur_target.global_pos.x:
							return NPC.Actions.RIGHT
						else:
							return NPC.Actions.LEFT
					# 惊吓观测吓一跳然后逃跑
					Observation.ObservationType.SCARE:
						_change_state(ActorStates.SCARED)
						return NPC.Actions.SCARE
					# 终极惊吓吓一跳然后一直往右跑路
					Observation.ObservationType.FINAL_SCARE:
						_change_state(ActorStates.FINAL_SCARED)
						return NPC.Actions.SCARE

	return NPC.Actions.IDLE

func _change_state(new_state: ActorStates):
	cur_state = new_state
	time_in_cur_state = 0.0
