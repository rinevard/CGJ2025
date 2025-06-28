class_name Ghost extends CharacterBody2D

enum States {
	NORMAL,
	POSSESSING
}

var state: States = States.NORMAL
var possessed_item: Item = null

@onready var detect_area: Area2D = $DetectArea
var neighbor_items: Array[Item] = [] # 由 detect_item_area 负责维护

var speed: float = 400.0

func _physics_process(delta: float) -> void:
	match state:
		States.NORMAL:
			var horizontal_dir = Input.get_axis("left", "right")
			var vertical_dir = Input.get_axis("up", "down")
			var dir = Vector2(horizontal_dir, vertical_dir)
			velocity = dir * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	match state:
		States.NORMAL:
			# 附身
			if neighbor_items.size() > 0 and event.is_action_pressed("possess"):
				_possess()
		States.POSSESSING:
			# 激活物品
			if event.is_action_pressed("active"):
				possessed_item.activate()
			# 解除附身
			if event.is_action_pressed("inpossess"):
				_inpossess()

func _possess() -> void:
	MusicPlayer.mute_ghost()
	velocity = Vector2.ZERO
	possessed_item = neighbor_items.back()
	state = States.POSSESSING

func _inpossess() -> void:
	MusicPlayer.open_ghost()
	possessed_item = null
	state = States.NORMAL

func _on_detect_item_area_area_entered(area: Area2D) -> void:
	# 检测到 item area 时, 记录它
	var area_parent = area.get_parent()
	if area_parent is Item:
		neighbor_items.append(area_parent)
	#elif area_parent is SoulPoint:
		#pick_soul_point()
		#area_parent.die()
	else:
		print("Detecting an area whose parent is not Item!")

func _on_detect_item_area_area_exited(area: Area2D) -> void:
	# 离开 item area 时, 删除对它的记录(如果有)
	var area_parent = area.get_parent()
	if area_parent is Item and neighbor_items.has(area_parent):
		neighbor_items.erase(area_parent)

# var soul_power: int = 0
# func pick_soul_point() -> void:
# 	UITalker.soul_power += 1
