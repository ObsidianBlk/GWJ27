extends Node
class_name State


signal finished(next_state)

var host = null

func enter(host : Node):
	self.host = host

func resume(host : Node):
	self.host = host

func exit():
	self.host = null

func pause():
	pass

func handle_input(event):
	pass

func handle_update(delta):
	pass

func handle_physics(delta):
	pass
