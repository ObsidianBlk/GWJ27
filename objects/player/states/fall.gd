extends "res://objects/player/states/move.gd"


func enter(host : Node):
	.enter(host)
	self.host.play_animation("fall")

func resume(host : Node = null):
	.resume(host)
	self.host.play_animation("fall")

func pause():
	.pause()
	host.pause_animation()

func handle_physics(delta):
	if paused:
		return

	if host.is_grounded():
		host.velocity.y = 0
		if _get_direction() != 0:
			emit_signal("finished", "move")
		else:
			emit_signal("finished", "idle")
		return
	
	host.gravity(delta)
	host.move(delta, _get_direction())
	var res = host.update_velocity()
