extends Node2D

signal trigger

func _on_body_entered(body):
	emit_signal("trigger")
	self.queue_free()
