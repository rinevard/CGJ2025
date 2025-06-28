extends Camera2D

@export var follow_character: CharacterBody2D

## 相机跟随的平滑度。数值越小，相机移动越“滞后”；数值越大，跟随越紧密。
@export var smoothing_speed: float = 2.0
@export var room_width: float = 2880.0

var window_size

func _ready() -> void:
	window_size = get_viewport().get_visible_rect().size
	global_position.x = clamp(global_position.x, window_size.x / 2, room_width - window_size.x / 2)
	global_position.y = window_size.y / 2

func _physics_process(delta: float) -> void:
	if not follow_character:
		push_error("Camera's follower is not setted!")
		return
	var target_position = follow_character.global_position
	target_position.x = clamp(target_position.x, window_size.x / 2, room_width - window_size.x / 2)
	target_position.y = window_size.y / 2
	global_position = lerp(global_position, target_position, smoothing_speed * delta)
