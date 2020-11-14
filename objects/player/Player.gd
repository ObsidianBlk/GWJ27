extends KinematicBody2D


var ups = 128
var velocity = Vector2.ZERO


func _ready():
	pass # Replace with function body.


func _HDirection():
	var dir = 0
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if Input.is_action_pressed("move_right"):
		dir += 1
	return dir

func _VDirection():
	var dir = 0
	if Input.is_action_pressed("move_up"):
		dir -= 1
	if Input.is_action_pressed("move_down"):
		dir += 1
	return dir


func _physics_process(delta):
	var dir = _HDirection()
	if dir == 0:
		velocity.x = 0
	else:
		velocity.x += (ups * dir) * delta

	dir = _VDirection()
	if dir == 0:
		velocity.y = 0
	else:
		velocity.y += (ups * dir) * delta
	
	var res = move_and_slide(velocity, Vector2.ZERO)
	if res.x == 0:
		velocity.x = 0
	if res.y == 0:
		velocity.y = 0
	
	
