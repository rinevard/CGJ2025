extends Label

var texts: Array[String] = [
	"",
	"安东尼波利亚诺斯教授闯进了你的家！想办法赶走他！",
	"<W/A/S/D> 移动   <SPACE> 附身物体",
	"<SPACE> 行动  <Q> 离开物体",
	"试着不断恐吓教授，把教授从房间最右边赶出吧！",
	""
]

var player
var state:int = 1
var textid:int = 0
var alpha = 0.0
var time0 = 0.0
var time = 0.0
var time2 = 0.0

func _ready() -> void:
	player = get_tree().get_root().find_child("Ghost", true, false)
	self.modulate.a = 0.0
	self.visible = true

func _process(delta: float) -> void:
	time += delta
	if textid < state:
		alpha = lerp(alpha, 0.0, delta * 6.0)
		if alpha < 0.01:
			textid += 1
	else:
		alpha = lerp(alpha, 1.0, delta * 4.0)
	if state == 1 && time > 3.0:
		state = 2
	if state == 2 && player.state == Ghost.States.POSSESSING:
		state = 3
	if state == 3 && player.state == Ghost.States.NORMAL:
		state = 4
	if state == 4:
		time2 += delta
		if time2 >= 5.0:
			state = 5
	text = texts[textid]
	self.modulate.a = alpha
	
