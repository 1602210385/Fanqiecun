class_name 	statemachine
extends Node

var current_state: int = -1 : set =_change_state
func _change_state(new) -> void:
	owner.transition_state(current_state , new)
	current_state = new

func _ready() -> void:
	await owner.ready
	current_state = 0
	
func _physics_process(delta: float) -> void:
	while true:
		var next_state : int = owner.renew_state(current_state)
		if current_state == next_state:
			break
		current_state = next_state
		
	owner.tick_physics(current_state , delta)
