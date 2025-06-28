## 给 actor 提供 observations
class_name Observer extends Area2D

## 环境里的各个吸引点
var observations: Array[Observation] = []

func _on_area_entered(area: Area2D) -> void:
	# 遇到 NoiseArea 时更新 observations
	# NoiseArea 提供 obs, 我们把它加入列表
	print(area.name)
	if area is NoiseArea:
		var new_obs: Observation = area.get_obs()
		if new_obs == null:
			return
		for obs in observations:
			if Observation.is_equal(obs, new_obs):
				return
		observations.append(new_obs)

## 由 actor 调用, actor 根据当前观测返回对应行为
func get_observations() -> Array[Observation]:
	return observations

func get_last_observation() -> Observation:
	if observations.size() == 0:
		return null
	return observations.back()

## 在一个兴趣点被看完以后被调用, 移除这个兴趣点
func remove_observation(obs: Observation) -> void:
	observations.erase(obs)

## 在惊吓结束时被调用, 清空兴趣点
func clear_observation() -> void:
	observations = []
