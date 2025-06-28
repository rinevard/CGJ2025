class_name Observation extends Resource

enum ObservationType {
	NORMAL,
	ATTRACTION,	
	SCARE,
	FINAL_SCARE
}

# 越大越优先
var priori: int = 0
var typ: ObservationType = ObservationType.NORMAL
# 发出 obs 的 item 的 global_position
var global_pos: Vector2 = Vector2.ZERO
# 发出 obs 的 item
var source: Item = null

static func is_equal(obs1: Observation, obs2: Observation):
	return (obs1.typ == obs2.typ) and (obs1.global_pos == obs2.global_pos) and (obs1.source == obs2.source)

static func new_obs(p_typ: ObservationType, p_global_pos: Vector2, p_src: Node2D) -> Observation:
	var obs = Observation.new()
	obs.typ = p_typ
	obs.global_pos = p_global_pos
	obs.source = p_src
	obs.priori = int(obs.typ)
	return obs
