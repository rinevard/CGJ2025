extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
func _ready() -> void:
	animation_player.play("run")
