extends Node2D

@onready var room_handler: RoomHandler = $RoomHandler

func _ready() -> void:
	MusicPlayer.play_bgm()
	SignalHandler.exit_level.connect(_on_room_exit)

var is_changing: bool = false
func _on_room_exit(room_num: int) -> void:
	if is_changing:
		return
	is_changing = true

	await _transition_fade_in()
	SfXPlayer.stop_all_sfx()
	room_handler.change_room(room_num + 1)
	await _transition_fade_out()

	is_changing = false

#region 场景切换所用的 mask
@onready var transition_mask: ColorRect = $CanvasLayer/TransitionMask
var transition_duration: float = 1.0

func _transition_fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(transition_mask, "material:shader_parameter/progress", 1.0, transition_duration)
	await tween.finished

func _transition_fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(transition_mask, "material:shader_parameter/progress", 0.0, transition_duration)
	await tween.finished
#endregion
