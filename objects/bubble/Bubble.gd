extends Node2D

export (float, 0.0, 1.0) var size_variance = 0.0
export (float, 0.0, 200.0) var wave_length = 10.0
export (float, 0.0, 1.0) var wave_length_variance = 0.0
export (float, 0.1, 60.0) var wave_duration = 1.0
export (float, 0.1, 60.0) var life_time = 4.0
export (float, 0.0, 1.0) var life_variance = 0.0
export (float, 0.1, 10000.0) var lift_per_second = 40.0


var cur_life_time = 0.0
var cur_life = 0.0
var cur_wave_length = 0.0

func _calc_variance(base, variance):
	return base + (base * (rand_range(-variance, variance)))

func _ready():
	if size_variance > 0.0:
		$Viz.scale.x = _calc_variance($Viz.scale.x, size_variance)
		$Viz.scale.y = $Viz.scale.x
	
	cur_life_time = _calc_variance(life_time, life_variance)
	cur_wave_length = _calc_variance(wave_length, wave_length_variance)
	$Tween_Death.connect("tween_all_completed", self, "_on_dead")
	$Tween_Wave.connect("tween_all_completed", self, "_on_wave_shift")
	
	$Tween_Wave.interpolate_property($Viz, "position:x", $Viz.position.x, cur_wave_length * 0.5, wave_duration * 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween_Wave.start()
	
	var lift_duration = cur_life_time + (cur_life_time * 0.5)
	var lift_distance = lift_per_second * lift_duration

func _physics_process(delta):
	global_position.y -= lift_per_second * delta
	
	if cur_life >= 0:
		cur_life += delta
		if cur_life >= cur_life_time:
			cur_life = -1
			$Tween_Death.interpolate_property($Viz, "modulate", $Viz.modulate, Color(1.0, 1.0, 1.0, 0.0), cur_life_time * 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween_Death.interpolate_property($Viz, "scale", $Viz.scale, Vector2(0.0, 0.0), cur_life_time * 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween_Death.start()


func _on_wave_shift():
	var target = (cur_wave_length * 0.5)
	if $Viz.position.x > 0:
		target = -(cur_wave_length * 0.5)
	$Tween_Wave.interpolate_property($Viz, "position:x", $Viz.position.x, target, wave_duration * 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween_Wave.start()

func _on_dead():
	self.queue_free()
