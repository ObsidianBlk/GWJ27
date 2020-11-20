extends Node2D

signal trigger

func _on_body_entered(body):
	if body.has_method("attach_book"):
		body.attach_book(self)
		$PickupArea.monitoring = false
		$Viz/Light.scale = Vector2(2, 2)
		#$Viz/Light.enabled = false
		emit_signal("trigger")
