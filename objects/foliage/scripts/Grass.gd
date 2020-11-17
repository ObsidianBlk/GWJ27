tool
extends Node2D

export var color : Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_color
export var grow_time : float = 2.0
export var bloomed : bool = true setget _set_bloomed
export var start_growing : bool = false

export(float, 0.0, 1.0) var wind_variance : float = 0.2 setget _set_wind_variance


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
			$cluster.scale.y = 1.0
		else:
			$cluster.scale.y = 0.0


func _set_wind_variance(v : float, force : bool = false):
	v = clamp(v, 0.0, 1.0)
	if v != wind_variance or force:
		wind_variance = v
		if ready:
			var mat = $cluster.get_material()
			mat.set_shader_param("strengthScale", 50 + (rand_range(-(50 * wind_variance), 50 * wind_variance)))
			mat.set_shader_param("minStrength", 0.1 + rand_range(0.0, 0.1 * wind_variance))
			mat.set_shader_param("maxStrength", 0.2 + rand_range(0.0, 0.2 * wind_variance))

func _ready():
	ready = true
	_set_color(color, true)
	_set_wind_variance(wind_variance, true)
	_set_bloomed(bloomed)
	if not bloomed and start_growing and not Engine.editor_hint:
		grow()

func grow():
	if not grown:
		grown = true
		$cluster.scale.y
		$Tween.interpolate_property($cluster, "scale:y", $cluster.scale.y, 1.0, grow_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

