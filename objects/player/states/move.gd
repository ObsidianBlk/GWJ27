extends "res://scripts/State.gd"


func enter(host : Node):
	.enter(host)

func handle_physics(delta):
	if host.velocity.x == 0:
		emit_signal("finished", "idle")
		return

	if not host.is_grounded():
		emit_signal("finished", "fall")
		return
	
	if _jumping():
		return
	
	var dir = _get_direction()
	if dir != 0:
		host.move(delta, dir)
		var res = host.update_velocity(true)
		if res.x == 0:
			host.velocity.x = 0
	else:
		host.velocity.x = 0


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
