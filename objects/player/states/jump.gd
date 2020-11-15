extends "res://objects/player/states/move.gd"


func enter(host : Node):
	.enter(host)
	host.jump()
	host.play_animation("jump")


func handle_physics(delta):
	if host.hit_ceiling():
		host.velocity.y = 0

	if host.velocity.y >= 0:
		emit_signal("finished", "fall")
		return
	
	host.gravity(delta)
	host.move(delta, _get_direction())
	var res = host.update_velocity()
