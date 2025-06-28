extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var ghost_float_player: AudioStreamPlayer = $GhostFloatPlayer

func play_bgm() -> void:
	bgm_player.play()
	ghost_float_player.play()

var tween_duration: float = 1.0
func mute_ghost() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(ghost_float_player, "volume_db", -10.0, tween_duration)
	await tween.finished

func open_ghost() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(ghost_float_player, "volume_db", 0.0, tween_duration)
	await tween.finished
