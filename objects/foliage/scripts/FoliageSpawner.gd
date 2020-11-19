tool
extends Node2D

const LIGHT_BOX_BASE_WIDTH = 32.0
const GRASS_WIDTH = 32.0

var grass = preload("res://objects/foliage/Grass.tscn")
var bubble = preload("res://objects/bubble/Bubble.tscn")

enum ANCHOR {
	LEFT,
	CENTER,
	RIGHT
}

export (float, 32.0, 3200.0) var area = 128 setget _set_area
export (ANCHOR) var anchor = ANCHOR.CENTER setget _set_anchor
export (float, 0.0, 32.0) var bg_y_offset setget _set_bg_y_offset
export (float, 0.0, 32.0) var fg_y_offset setget _set_fg_y_offset
export var bg_container_path : NodePath = ""
export var fg_container_path : NodePath = ""
export (float, 0.0, 1.0) var grow_rate = 0.2
export (float, 0.1, 1.0) var spread = 1.0
export (float, 0.0, 1.0) var variance = 0.0
export var grow_on_start : bool = false
export var grass_color : Color = Color(0.25, 1.0, 0.0, 1.0)
export (float, 0.0, 100.0) var bubbles_per_second = 4.0

var bg_container = null
var fg_container = null

var grass_list = []
var grass_to_spawn = 0
var grass_dist = 0
var spawn_count = 0
var last_l_offset = 0
var last_r_offset = 0
var last_spawn_side = 0 # 0 = center | 1 = right | -1 = left

var light_max_x_scale = 0.0

var bubble_spawn_count = 0


func _calc_light_y_scale():
	# NOTE... Light box is square, so it's width and height are the same.
	# So ignore the "_WIDTH" part.
	var off_dist = (LIGHT_BOX_BASE_WIDTH * 2) + bg_y_offset + fg_y_offset + GRASS_WIDTH
	$Light.scale.y = off_dist / (LIGHT_BOX_BASE_WIDTH * 2)

func _set_area(a: float):
	if a != area:
		area = clamp(a, 32.0, 3200.0)
		update()

func _set_bg_y_offset(off : float):
	off = clamp(off, 0.0, 32.0)
	if off != bg_y_offset:
		bg_y_offset = off
		_calc_light_y_scale()
		update()

func _set_fg_y_offset(off : float):
	off = clamp(off, 0.0, 32.0)
	if off != fg_y_offset:
		fg_y_offset = off
		_calc_light_y_scale()
		update()

func _set_anchor(a):
	if a != anchor:
		anchor = a
		match(anchor):
			ANCHOR.LEFT:
				$Light.offset.x = -(LIGHT_BOX_BASE_WIDTH * 0.5)
				$Light.position.x = (LIGHT_BOX_BASE_WIDTH * 0.5)
			ANCHOR.RIGHT:
				$Light.offset.x = (LIGHT_BOX_BASE_WIDTH * 0.5)
				$Light.position.x = -(LIGHT_BOX_BASE_WIDTH * 0.5)
			ANCHOR.CENTER:
				$Light.offset.x = 0
				$Light.position.x = 0
		update()


func _ready():
	set_process(false)
	bg_container = get_node(bg_container_path)
	fg_container = get_node(fg_container_path)
	grass_dist = GRASS_WIDTH * spread
	grass_to_spawn = floor(area / grass_dist)
	
	light_max_x_scale = (area / LIGHT_BOX_BASE_WIDTH) + 1
	
	update()
	if grow_on_start:
		grow()


func grow():
	if not Engine.editor_hint:
		var gps = grow_rate * grass_to_spawn
		var duration = grass_to_spawn / gps
		$Light.enabled = true
		$Tween.interpolate_property($Light, "scale:x", $Light.scale.x, light_max_x_scale, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		set_process(true)

func _process(delta):
	if not Engine.editor_hint:
		if grass_list.size() < (grass_to_spawn * 2):
			spawn_count += delta * grow_rate * grass_to_spawn
			if spawn_count < 1.0:
				return
			
			# Only keep the fraction
			var count = floor(spawn_count)
			spawn_count -= count
			
			match(anchor):
				ANCHOR.LEFT:
					_spawnDirectional(count, -1)
				ANCHOR.RIGHT:
					_spawnDirectional(count, 1)
				ANCHOR.CENTER:
					_spawnCenterGrass(count)

		bubble_spawn_count += delta * bubbles_per_second
		if bubble_spawn_count >= 1.0:
			var count = floor(bubble_spawn_count)
			bubble_spawn_count -= count
			
			for i in range(0.0, count):
				_spawn_bubble()


func _spawn_bubble():
	if bg_container == null:
		return
	
	var b = bubble.instance()
	var posx = global_position.x
	match(anchor):
		ANCHOR.LEFT:
			posx -= rand_range(0.0, area)
		ANCHOR.RIGHT:
			posx += rand_range(0.0, area)
		ANCHOR.CENTER:
			posx += rand_range(-(area*0.5), area*0.5)
	b.position.x = posx
	b.position.y = global_position.y - bg_y_offset
	bg_container.add_child(b)
	


func variant_dist():
	if variance == 0:
		return grass_dist
	return grass_dist + ((grass_dist*0.5) * rand_range(0.0, variance))


func _spawnDirectional(count, dir):
	for i in range(0, count):
		if last_l_offset >= area:
			grass_to_spawn = grass_list.size() * 0.5
			return

		if grass_list.size() <= 0:
			_spawn(global_position)
		else:
			var dist = variant_dist()
			last_l_offset += dist
			if last_l_offset > area:
				last_l_offset = area
			var pos = global_position
			pos.x += dir * last_l_offset
			_spawn(pos)

func _spawnCenterGrass(count):
	var harea = area * 0.5
	for i in range(0, count):
		var off = 0.0
		if last_l_offset <= -harea or last_r_offset >= harea:
			grass_to_spawn = grass_list.size() * 0.5
			return

		if last_spawn_side < 0:
			last_l_offset -= variant_dist()
			if last_l_offset < -harea:
				last_l_offset = -harea
			off = last_l_offset
		elif last_spawn_side > 0:
			last_r_offset += variant_dist()
			if last_r_offset > harea:
				last_r_offset = harea
			off = last_r_offset
		else:
			last_spawn_side = 1
		last_spawn_side *= -1
			
		var pos = global_position
		pos.x += off
		_spawn(pos)


func _spawn(pos):
	if bg_container != null:
		_createGrassIn(bg_container, Vector2(pos.x, pos.y - bg_y_offset))
	if fg_container != null:
		_createGrassIn(fg_container, Vector2(pos.x, pos.y + fg_y_offset))


func _createGrassIn(container, pos):
	var g = grass.instance()
	g.bloomed = false
	g.start_growing = true
	g.color = grass_color
	g.position = pos
	container.add_child(g)
	grass_list.append(g)


func _draw():
	if Engine.editor_hint:
		var guide_color = Color(0.25, 1.0, 0.0)
		var offset_color = Color(0.0, 0.25, 1.0)
		var r1 = null
		var r2 = null
		match(anchor):
			ANCHOR.CENTER:
				var h = area * 0.5
				r1 = Rect2(-h, -4.0, h - 16.0, 8.0)
				r2 = Rect2(16, -4, h - 16.0, 8)
			ANCHOR.LEFT:
				r1 = Rect2(-area, -4.0, area - 16.0, 8.0)
			ANCHOR.RIGHT:
				r1 = Rect2(16.0, -4.0, area - 16.0, 8.0)
		draw_rect(Rect2(-16, -16, 32.0, 32.0), guide_color, false, 2.0)
		
		draw_rect(r1, guide_color, true)
		r1.position.y = -bg_y_offset
		r1.size.y = 4.0
		draw_rect(r1, offset_color, true)
		r1.position.y = fg_y_offset
		draw_rect(r1, offset_color, true)
		if r2 != null:
			draw_rect(r2, guide_color, true)
			r2.position.y = -bg_y_offset
			r2.size.y = 4.0
			draw_rect(r2, offset_color, true)
			r2.position.y = fg_y_offset
			draw_rect(r2, offset_color, true)



