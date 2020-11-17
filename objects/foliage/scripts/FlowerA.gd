tool
extends Node2D


export var stalk_color : Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_stalk_color
export var peddle_color : Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_peddle_color
export var bulb_color : Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_bulb_color
export var bloomed : bool = true setget _set_bloomed
export var start_growing : bool = false

var ready = false
var grown = false

func _set_stalk_color(c : Color, force : bool = false):
	if c != stalk_color or force:
		stalk_color = c
		if ready:
			for child in $Stalk.get_children():
				if child is Sprite:
					child.modulate = stalk_color

func _set_peddle_color(c : Color, force : bool = false):
	if c != peddle_color or force:
		peddle_color = c
		if ready:
			for child in $Bloom.get_children():
				if child is Sprite:
					child.modulate = peddle_color

func _set_bulb_color(c : Color, force : bool = false):
	if c != bulb_color or force:
		bulb_color = c
		if ready:
			$"Pollin Bulb".modulate = bulb_color

func _set_bloomed(b : bool):
	bloomed = b
	if ready:
		if bloomed:
			$Anim.play("final")
		else:
			grown = false
			if start_growing and not Engine.editor_hint:
				$Anim.play("grow")
			else:
				$Anim.play("init")

func _ready():
	ready = true
	_set_stalk_color(stalk_color, true)
	_set_peddle_color(peddle_color, true)
	_set_bulb_color(bulb_color, true)
	_set_bloomed(bloomed)
	if start_growing and not Engine.editor_hint:
		grow()

func grow():
	if not grown:
		$Anim.play("grow")


func _on_animation_finished(anim_name):
	if anim_name == "grow":
		grown = true
		$Anim.play("final")
