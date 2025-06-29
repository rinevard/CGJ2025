extends Area2D

@export var level_num: int = 0

func _on_body_entered(body: Node2D) -> void:
	if body is NPC:
		SignalHandler.exit_level.emit(level_num)
