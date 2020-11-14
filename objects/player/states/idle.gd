extends "res://objects/player/states/move.gd"


func handle_physics(delta):
	if not host.is_grounded():
		emit_signal("finished", "fall")
		return
	
	if _jumping():
		return

	var dir = _get_direction()
	if dir != 0:
		host.move(delta, dir)
		emit_signal("finished", "move")
		return
