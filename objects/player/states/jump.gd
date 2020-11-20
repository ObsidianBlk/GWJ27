extends "res://objects/player/states/move.gd"


func enter(host : Node):
	.enter(host)
	self.host.jump()
	self.host.play_animation("jump")

func resume(host : Node = null):
	.resume(host)
	self.host.play_animation("jump")

func pause():
	.pause()
	host.pause_animation()


func handle_physics(delta):
	if paused:
		return

	if host.hit_ceiling():
		host.velocity.y = 0

	if host.velocity.y >= 0:
		emit_signal("finished", "fall")
		return
	
	host.gravity(delta)
	_move(delta)
