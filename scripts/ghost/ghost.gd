class_name Ghost extends Node2D

enum States {
	NORMAL,
	POSSESSING
}

var state: States = States.NORMAL
var possessed_item: Item = null

@onready var detect_item_area: Area2D = $DetectItemArea
var neighbor_item: Item = null # 由 detect_item_area 负责维护

var speed: float = 400.0
func _physics_process(delta: float) -> void:
	match state:
		States.NORMAL:
			var horizontal_dir = Input.get_axis("left", "right")
			var vertical_dir = Input.get_axis("up", "down")
			var dir = Vector2(horizontal_dir, vertical_dir)
			global_position += dir * speed * delta

func _unhandled_input(event: InputEvent) -> void:
	match state:
		States.NORMAL:
			# 附身
			if neighbor_item and event.is_action_pressed("possess"):
				_possess(neighbor_item)
		States.POSSESSING:
			# 激活物品
			if event.is_action_pressed("active"):
				possessed_item.activate()
			# 解除附身
			if event.is_action_pressed("inpossess"):
				_inpossess()

func _possess(item: Item) -> void:
	possessed_item = item
	state = States.POSSESSING

func _inpossess() -> void:
	possessed_item = null
	state = States.NORMAL

func _on_detect_item_area_area_entered(area: Area2D) -> void:
	# 检测到 item area 时, 记录它
	var area_parent = area.get_parent()
	if area_parent is Item:
		neighbor_item = area_parent
	else:
		print("Detecting an area whose parent is not Item!")

func _on_detect_item_area_area_exited(area: Area2D) -> void:
	# 离开 item area 时, 删除对它的记录(如果有)
	var area_parent = area.get_parent()
	if area_parent is Item and area_parent == neighbor_item:
		neighbor_item = null
