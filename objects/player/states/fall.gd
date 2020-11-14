extends "res://objects/player/states/move.gd"


func handle_physics(delta):
	if host.is_grounded():
		if _get_direction() != 0:
			emit_signal("finished", "move")
		else:
			emit_signal("finished", "idle")
		return
	
	host.gravity(delta)
	host.move(delta, _get_direction())
	var res = host.update_velocity()
