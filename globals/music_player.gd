extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var ghost_float_player: AudioStreamPlayer = $GhostFloatPlayer

## 由 main 在游戏开始时调用
func play_bgm() -> void:
	bgm_player.play()
	ghost_float_player.play()

var tween_duration: float = 0.6
var mute_db: float = -30.0

## 静音幽灵轨道
func mute_ghost() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(ghost_float_player, "volume_db", mute_db, tween_duration)
	await tween.finished

## 打开幽灵轨道
func open_ghost() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(ghost_float_player, "volume_db", 0.0, tween_duration)
	await tween.finished
