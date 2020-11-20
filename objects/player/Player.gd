extends KinematicBody2D

export var pixels_per_unit = 10.0
export var units_per_second = 50.0
export var jump_unit_height = 12.0
export var jump_max_seconds = 0.4

var jump_power = 0
var gravity = 0
var speed = 0
var velocity = Vector2.ZERO

onready var bookContainer_node = $Character/Polygons/HandR/BookContainer
onready var handBone_node = $Character/Skeleton2D/Hip/Chest/ArmR/ForearmR/HandR
onready var bookContainer_localX_offset = bookContainer_node.position.x
var bookContainer_pos_offset = Vector2.ZERO
var bookContainer_rot_offset = Vector2.ZERO


func _ready():
	var pre_gravity = (2.0 * jump_unit_height)/(jump_max_seconds * jump_max_seconds)
	gravity = pre_gravity * pixels_per_unit
	jump_power = sqrt(2 * pre_gravity * jump_unit_height) * pixels_per_unit
	speed = units_per_second * pixels_per_unit
	
	bookContainer_pos_offset = handBone_node.global_position - bookContainer_node.global_position
	bookContainer_rot_offset = handBone_node.global_rotation - bookContainer_node.global_rotation

func _process(delta):
	bookContainer_node.global_position = handBone_node.global_position - bookContainer_pos_offset
	bookContainer_node.global_rotation = handBone_node.global_rotation - bookContainer_rot_offset
	if $Character.scale.x < 0:
		bookContainer_node.position.x += bookContainer_localX_offset 

func attach_book(book : Node2D):
	if not book_attached():
		book.get_parent().remove_child(book)
		book.position = Vector2.ZERO
		bookContainer_node.add_child(book)

func book_attached():
	return bookContainer_node.get_child_count() > 0

func get_facing():
	if $Character.scale.x < 0:
		return -1
	return 1

func move(delta : float, dir : int, multi : float = 1.0):
	if dir != 0:
		if dir != get_facing():
			$Character.scale.x *= -1
			
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

func is_against_wall(dir : int = 0):
	if dir == 0:
		return (is_against_wall(-1) or is_against_wall(1))
	if dir > 0:
		return ($WallRay_LowerRight.is_colliding() or $WallRay_UpperRight.is_colliding())
	return ($WallRay_LowerLeft.is_colliding() or $WallRay_UpperLeft.is_colliding())

func update_velocity(snap : bool = false):
	if snap:
		return move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	return move_and_slide(velocity, Vector2.UP)

func play_animation(anim_name : String):
	if $Character/Anim.has_animation(anim_name):
		$Character/Anim.play(anim_name)

func pause_animation():
	if $Character/Anim.is_playing():
		$Character/Anim.stop(false)

func current_animation():
	return $Character/Anim.current_animation


func _on_input_disable():
	$FSM.pause()
	#$FSM.process_handlers(false)

func _on_input_enable():
	$FSM.resume()
	#$FSM.process_handlers(true)



