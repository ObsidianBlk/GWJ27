extends Node2D

signal trigger

func _on_body_entered(body):
	if body.has_method("book_attached"):
		print("I have the method!")
		if body.book_attached():
			emit_signal("trigger")
			self.queue_free()
