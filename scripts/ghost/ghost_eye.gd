class_name GhostEye extends Node2D

# @onready 确保在脚本第一次使用这些变量之前，它们已经被正确赋值
@onready var inner_eye: Sprite2D = $InnerEye
@onready var out_eye: Sprite2D = $OutEye

# 内眼（瞳孔）可以从中心移动的最大偏移量
const MAX_X_BIAS = 4.0
const MAX_Y_BIAS = 4.0

# 鼠标相对于屏幕中心的最大距离（这里假设屏幕分辨率为1920x1080）
# 这个值用来计算鼠标位置的比例
const MAX_X_DIS = 1920 / 10.0
const MAX_Y_DIS = 1080 / 2.0

# 这个函数计算并设置内眼的位置
func _eye_follow(target: Vector2) -> void:
	var direction = target - out_eye.global_position

	var x_ratio = direction.x / MAX_X_DIS
	var y_ratio = direction.y / MAX_Y_DIS

	# 3. 根据这个比例，计算内眼应该在X和Y轴上偏移多少
	#    我们将屏幕的大范围移动映射到眼睛的小范围移动
	var x_offset = x_ratio * MAX_X_BIAS
	var y_offset = y_ratio * MAX_Y_BIAS

	# 4. 创建一个最终的偏移向量，并进行“钳制”（clamp）
	#    clampf函数确保偏移量不会超过我们设定的最大值（MAX_..._BIAS）
	#    这样即使鼠标移动到屏幕很远的地方，瞳孔也不会跑出眼眶
	var final_offset = Vector2(
		clampf(x_offset, -MAX_X_BIAS, MAX_X_BIAS),
		clampf(y_offset, -MAX_Y_BIAS, MAX_Y_BIAS)
	)

	# 5. 将计算出的最终偏移量应用到内眼的“局部”位置上
	#    因为 inner_eye 是这个 Node2D 的子节点，所以设置它的 position
	#    就会让它相对于父节点（也就是眼睛的中心）移动
	inner_eye.position = final_offset
	print(final_offset)
