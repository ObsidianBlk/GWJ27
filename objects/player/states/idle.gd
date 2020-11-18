extends "res://objects/player/states/move.gd"


func enter(host : Node):
	.enter(host)
	self.host.play_animation("idle")

func handle_physics(delta):
	if paused:
		return

	if not host.is_grounded():
		emit_signal("finished", "fall")
		return
	
	if _jumping():
		return

	var dir = _get_direction()
	if dir != 0:
		if not host.is_against_wall(dir):
			host.move(delta, dir)
			emit_signal("finished", "move")
			return
