class_name Ghost extends CharacterBody2D

enum States {
	NORMAL,
	POSSESSING
}

var state: States = States.NORMAL
var possessed_item: Item = null

@onready var detect_area: Area2D = $DetectArea
var neighbor_items: Array[Item] = [] # 由 detect_item_area 负责维护

var speed: float = 450.0
@onready var smoothing_speed: Vector2 = Vector2(6.0, 8.0) # 平滑过渡速度

var target_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match state:
		States.NORMAL:
			var horizontal_dir = Input.get_axis("left", "right")
			var vertical_dir = Input.get_axis("up", "down")
			var dir = Vector2(horizontal_dir, vertical_dir)
			if dir.length() > 1.0:
				dir = dir.normalized() # 保证斜向和轴向速度相同
			target_velocity = dir * speed
		_:
			# 其它状态下, 速度归零
			target_velocity = Vector2.ZERO
			velocity = Vector2.ZERO
	# 黏糊糊手感
	# x 和 y 用不同的参数是考虑到幽灵看起来是浮起来的，所以 y 轴启动快衰减也快。
	velocity.x = lerp(velocity.x, target_velocity.x, smoothing_speed.x * delta)
	velocity.y = lerp(velocity.y, target_velocity.y, smoothing_speed.y * delta)
	_flip_if_needed()
	_move_item_if_needed(delta)
	move_and_slide()

@export var enable_move_item: bool = false
func _move_item_if_needed(delta: float) -> void:
	if not enable_move_item or not possessed_item:
		return
	var horizontal_dir = Input.get_axis("left", "right")
	possessed_item.move(horizontal_dir, delta)

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

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var flip_duration: float = 0.2
var is_flipping: bool = false
func _flip_if_needed() -> void:
	# 如果正在翻转，或者水平速度为0，则不执行任何操作
	if is_flipping or velocity.x == 0:
		return

	# 判断精灵是否应该被翻转 (velocity.x > 0 意味着应该朝右, 应当翻转)
	var should_be_flipped: bool = velocity.x > 0

	if animated_sprite_2d.flip_h != should_be_flipped:
		is_flipping = true
		var abs_scale_x: float = abs(animated_sprite_2d.scale.x)

		var tween = create_tween()
		tween.set_parallel(false)
	
		tween.tween_property(animated_sprite_2d, "scale:x", 0.0, flip_duration / 2.0)
		# 在动画中途，更新 flip_h 属性
		tween.tween_callback(func(): animated_sprite_2d.flip_h = should_be_flipped)
		tween.tween_property(animated_sprite_2d, "scale:x", abs_scale_x, flip_duration / 2.0)
		
		# 第四步：动画完成后，重置状态
		tween.finished.connect(func(): is_flipping = false)
