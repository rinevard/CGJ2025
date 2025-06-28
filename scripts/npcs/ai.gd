class_name AI extends Node2D
@onready var actor: Actor = $Actor
@onready var observer: Observer = $Observer

func get_action(delta: float) -> NPC.Actions:
	var action = actor.get_action(observer.get_last_observation(), delta)
	return action

func _on_actor_obs_entered(obs: Observation) -> void:
	observer.remove_observation(obs)

func _on_actor_scare_ended() -> void:
	observer.clear_observation()
