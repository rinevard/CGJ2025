## actor 根据 observations 返回动作
extends Area2D

## 环境里的各个吸引点
var observations: Array[Observation] = []

func _on_area_entered(area: Area2D) -> void:
	# 遇到 NoiseArea 时更新 observations
	# NoiseArea 提供 obs, 我们把它加入列表
	if area is NoiseArea:
		var new_obs: Observation = area.get_obs()
		if new_obs == null:
			return
		for obs in observations:
			if Observation.is_equal(obs, new_obs):
				return
		observations.append(new_obs)

func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.

## 由 actor 调用, actor 根据当前观测返回对应行为
func get_observations() -> Array[Observation]:
	return observations

## 在一个兴趣点被看完以后被调用, 移除这个兴趣点
func remove_observation(obs: Observation) -> void:
	pass

## 在惊吓结束时被调用, 清空兴趣点
func clear_observation() -> void:
	observations = []
