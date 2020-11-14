extends Camera2D


export var target_path : NodePath = "" setget _set_target_path
export var duration : float = 0.25

var ready = false
var target = null

var last_position = Vector2.ZERO


func _set_target_path(path, force = false):
	if path != target_path or force:
		if ready:
			if path == "":
				target = null
				target_path = ""
			else:
				var ntarget = get_node(path)
				if ntarget != null:
					target_path = path
					target = ntarget
		else:
			target_path = path


func _ready():
	ready = true
	_set_target_path(target_path, true)


func _physics_process(delta):
	if target != null:
		if target.global_position != last_position:
			last_position = target.global_position
			$Tween.interpolate_property(self, "global_position", self.global_position, target.global_position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
