tool
extends Node2D

export var color : Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_color
export var grow_time : float = 2.0
export var bloomed : bool = true setget _set_bloomed
export var start_growing : bool = false


var ready = false
var grown = false

func _set_color(c : Color, force : bool = false):
	if c != color or force:
		color = c
		if ready:
			$cluster.modulate = color


func _set_bloomed(b : bool):
	bloomed = b
	if ready:
		if bloomed:
			$cluster.scale.x = 1.0
		else:
			$cluster.scale.x = 0.0

func _ready():
	ready = true
	_set_bloomed(bloomed)
	if not bloomed and start_growing and not Engine.editor_hint:
		grow()


func grow():
	if not grown:
		grown = true
		$cluster.scale.x
		$Tween.interpolate_property($cluster, "scale.x", $cluster.scale.x, 1.0, grow_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

