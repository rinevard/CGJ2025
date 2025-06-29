extends Control
@onready var heartrate_label: Label = $Heartrate/Heartrate_Label

func _ready() -> void:
	_init_heartrate()

func _process(delta: float) -> void:
	_update_heartrate(delta)


######################## 心跳相关 ########################
const heartrate_update_freq: float = 1.3
var time_from_last_heartrate_update: float = 0.0

var max_update_step: int = 4
var cur_heartrate: int = round((UITalker.heart_beat_lower + UITalker.heart_beat_upper) / 2.0)

func _init_heartrate() -> void:
	heartrate_label.text = str(cur_heartrate)

func _update_heartrate(delta: float) -> void:
	time_from_last_heartrate_update += delta
	if time_from_last_heartrate_update > heartrate_update_freq:
		time_from_last_heartrate_update = 0.0

		cur_heartrate += randi_range(-max_update_step, max_update_step)
		cur_heartrate = clamp(cur_heartrate, UITalker.heart_beat_lower, UITalker.heart_beat_upper)
		heartrate_label.text = str(cur_heartrate)
