extends Node

const CAT = preload("res://assets/sfx/cat.ogg")
const DOOR_CREAK = preload("res://assets/sfx/door_creak.ogg")
const DOOR_SLAM = preload("res://assets/sfx/door_slam.ogg")
const FEAR_POINT_COLLECT = preload("res://assets/sfx/fear_point_collect.ogg")
const FOOTSTEP_WOOD_LOOP_FAST = preload("res://assets/sfx/footstep_wood_loop_fast.ogg")
const FOOTSTEP_WOOD_LOOP_NORMAL = preload("res://assets/sfx/footstep_wood_loop_normal.ogg")
const GHOST_POSSESS = preload("res://assets/sfx/ghost_possess.ogg")
const GHOST_UNPOSSESS = preload("res://assets/sfx/ghost_unpossess.ogg")
const HEARTBEAT_SLOW_LOOP = preload("res://assets/sfx/heartbeat_slow_loop.ogg")
const LIGHT_SWITCH = preload("res://assets/sfx/light_switch.ogg")
const NPC_GASP_1 = preload("res://assets/sfx/npc_gasp1.ogg")
const NPC_GASP_2 = preload("res://assets/sfx/npc_gasp2.ogg")
const NPC_SCREAM_FEMALE = preload("res://assets/sfx/npc_scream_female.ogg")
const PHONE_RING = preload("res://assets/sfx/phone_ring.ogg")
const TOY_LAUGH_CREEPY = preload("res://assets/sfx/toy_laugh_creepy.ogg")
const TV_STATIC_LOOP = preload("res://assets/sfx/tv_static_loop.ogg")

enum SFXs {
	CAT,
	DOOR_CREAK,
	DOOR_SLAM,
	FEAR_POINT_COLLECT,
	FOOTSTEP_WOOD_LOOP_FAST,
	FOOTSTEP_WOOD_LOOP_NORMAL,
	GHOST_POSSESS,
	GHOST_UNPOSSESS,
	HEARTBEAT_SLOW_LOOP,
	LIGHT_SWITCH,
	NPC_GASP_1,
	NPC_GASP_2,
	NPC_SCREAM_FEMALE,
	PHONE_RING,
	TOY_LAUGH_CREEPY,
	TV_STATIC_LOOP,
}

var audio_player_cnt: int = 10
var audio_players: Array[AudioStreamPlayer2D]

# 将枚举值映射到对应的音效资源
var sfx_map: Dictionary

func _ready() -> void:
	sfx_map = {
		SFXs.CAT: CAT,
		SFXs.DOOR_CREAK: DOOR_CREAK,
		SFXs.DOOR_SLAM: DOOR_SLAM,
		SFXs.FEAR_POINT_COLLECT: FEAR_POINT_COLLECT,
		SFXs.FOOTSTEP_WOOD_LOOP_FAST: FOOTSTEP_WOOD_LOOP_FAST,
		SFXs.FOOTSTEP_WOOD_LOOP_NORMAL: FOOTSTEP_WOOD_LOOP_NORMAL,
		SFXs.GHOST_POSSESS: GHOST_POSSESS,
		SFXs.GHOST_UNPOSSESS: GHOST_UNPOSSESS,
		SFXs.HEARTBEAT_SLOW_LOOP: HEARTBEAT_SLOW_LOOP,
		SFXs.LIGHT_SWITCH: LIGHT_SWITCH,
		SFXs.NPC_GASP_1: NPC_GASP_1,
		SFXs.NPC_GASP_2: NPC_GASP_2,
		SFXs.NPC_SCREAM_FEMALE: NPC_SCREAM_FEMALE,
		SFXs.PHONE_RING: PHONE_RING,
		SFXs.TOY_LAUGH_CREEPY: TOY_LAUGH_CREEPY,
		SFXs.TV_STATIC_LOOP: TV_STATIC_LOOP,
	}
	
	for i in range(audio_player_cnt):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		audio_players.append(player)


## 播放指定的音效
## sfx: 要播放的音效，来自于SFXs枚举
## global_pos: 音效在世界中的播放位置
func play_sfx(sfx: SFXs, global_pos: Vector2) -> void:
	# 首先检查传入的sfx是否有效，这是一个好习惯
	if not sfx_map.has(sfx):
		printerr("SFXManager: 尝试播放一个未在sfx_map中定义的音效: ", SFXs.keys()[sfx])
		return

	var sfx_stream = sfx_map[sfx]

	# 遍历播放器池，寻找空闲的播放器
	for player in audio_players:
		if not player.is_playing():
			player.stream = sfx_stream
			player.global_position = global_pos
			player.play()
			return

	# 如果循环结束后都没有找到空闲播放器
	# 新建播放器，添加到池中，并用它来播放。
	print_debug("SFXManager: 音效池已满，正在创建一个新的AudioStreamPlayer2D。当前池大小: ", audio_player_cnt)
	
	var new_player = AudioStreamPlayer2D.new()
	add_child(new_player)
	audio_players.append(new_player)
	audio_player_cnt += 1
	
	new_player.stream = sfx_stream
	new_player.global_position = global_pos
	new_player.play()
