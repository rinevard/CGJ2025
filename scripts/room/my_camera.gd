extends Camera2D

@export var follow_character: CharacterBody2D

## 相机跟随的平滑度。数值越小，相机移动越“滞后”；数值越大，跟随越紧密。
@export var smoothing_speed: float = 5.0

func _physics_process(delta: float) -> void:
	if not follow_character:
		push_error("Camera's follower is not setted!")
		return
	global_position = lerp(global_position, follow_character.global_position, smoothing_speed * delta)
