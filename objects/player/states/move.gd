extends "res://scripts/State.gd"


func enter(host : Node):
	.enter(host)
	self.host.play_animation("run")

func resume(host : Node = null):
	.resume(host)
	self.host.play_animation("run")

func pause():
	.pause()
	host.pause_animation()
	

func handle_physics(delta):
	if paused:
		return

	if host.velocity.x == 0:
		emit_signal("finished", "idle")
		return

	if not host.is_grounded():
		emit_signal("finished", "fall")
		return
	
	if _jumping():
		return
	
	_move(delta, true)

func _move(delta, snap = false):
	var dir = _get_direction()
	if dir != 0:
		host.move(delta, dir)
	else:
		host.velocity.x = 0
		
	var res = host.update_velocity(snap)
	if res.x == 0:
		host.velocity.x = 0
	return res

func _jumping():
	if Input.is_action_just_pressed("move_up"):
		emit_signal("finished", "jump")
		return true
	return false

func _get_direction():
	var dir = 0
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if Input.is_action_pressed("move_right"):
		dir += 1
	return dir
