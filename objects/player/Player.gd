extends KinematicBody2D

export var pixels_per_unit = 10.0
export var units_per_second = 50.0
export var jump_unit_height = 12.0
export var jump_max_seconds = 0.4

var jump_power = 0
var gravity = 0
var speed = 0
var velocity = Vector2.ZERO


func _ready():
	var pre_gravity = (2.0 * jump_unit_height)/(jump_max_seconds * jump_max_seconds)
	gravity = pre_gravity * pixels_per_unit
	jump_power = sqrt(2 * pre_gravity * jump_unit_height) * pixels_per_unit
	speed = units_per_second * pixels_per_unit

func move(delta : float, dir : int, multi : float = 1.0):
	if dir != 0:
		if (dir > 0 and velocity.x < 0) or (dir < 0 and velocity.x > 0):
			velocity.x = 0 
		velocity.x = clamp(velocity.x + (delta * dir * speed * multi), -speed, speed)

func jump():
	velocity.y = -jump_power

func gravity(delta):
	velocity.y += gravity * delta

func hit_ceiling():
	return is_on_ceiling()

func is_grounded():
	return is_on_floor()

func update_velocity(snap : bool = false):
	if snap:
		return move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	return move_and_slide(velocity, Vector2.UP)
