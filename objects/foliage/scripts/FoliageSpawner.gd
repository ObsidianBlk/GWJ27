tool
extends Node2D

const GRASS_WIDTH = 32.0

var grass = preload("res://objects/foliage/Grass.tscn")

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

var bg_container = null
var fg_container = null

var grass_list = []
var grass_to_spawn = 0
var grass_dist = 0
var spawn_count = 0
var last_l_offset = 0
var last_r_offset = 0
var last_spawn_side = 0 # 0 = center | 1 = right | -1 = left

func _set_area(a: float):
	if a != area:
		area = clamp(a, 32.0, 3200.0)
		update()

func _set_bg_y_offset(off : float):
	off = clamp(off, 0.0, 32.0)
	if off != bg_y_offset:
		bg_y_offset = off
		update()

func _set_fg_y_offset(off : float):
	off = clamp(off, 0.0, 32.0)
	if off != fg_y_offset:
		fg_y_offset = off
		update()

func _set_anchor(a):
	if a != anchor:
		anchor = a
		update()


func _ready():
	set_process(false)
	bg_container = get_node(bg_container_path)
	fg_container = get_node(fg_container_path)
	grass_dist = GRASS_WIDTH * spread
	grass_to_spawn = floor(area / grass_dist)
	update()
	if grow_on_start:
		grow()


func grow():
	if not Engine.editor_hint:
		set_process(true)

func _process(delta):
	if not Engine.editor_hint:
		if grass_list.size() >= (grass_to_spawn * 2):
			return

		spawn_count += delta * grow_rate * grass_to_spawn
		if spawn_count < 1.0:
			return
		
		# Only keep the fraction
		var count = floor(spawn_count)
		spawn_count -= count
		
		match(anchor):
			ANCHOR.LEFT:
				_spawnLeftgrass(count)
			ANCHOR.RIGHT:
				_spawnRightGrass(count)
			ANCHOR.CENTER:
				_spawnCenterGrass(count)


func variant_dist():
	if variance == 0:
		return grass_dist
	return grass_dist - (grass_dist * rand_range(0.0, variance))

func _spawnLeftgrass(count):
	for i in range(0, count):
		if grass_list.size() <= 0:
			_spawn(global_position)
		else:
			last_l_offset += variant_dist()
			var pos = global_position
			pos.x -= last_l_offset
			_spawn(pos)

func _spawnRightGrass(count):
	for i in range(0, count):
		if grass_list.size() <= 0:
			_spawn(global_position)
		else:
			last_r_offset += variant_dist()
			var pos = global_position
			pos.x += last_r_offset
			_spawn(pos)
			

func _spawnCenterGrass(count):
	for i in range(0, count):
		var off = 0.0
		if last_spawn_side < 0:
			last_l_offset -= variant_dist()
			off = last_l_offset
		elif last_spawn_side > 0:
			last_r_offset += variant_dist()
			off = last_r_offset
		else:
			last_spawn_side = 1
		last_spawn_side *= -1
			
		var pos = global_position
		pos.x += off
		_spawn(pos)


func _spawn(pos):
	if bg_container != null:
		var g = grass.instance()
		g.bloomed = false
		g.start_growing = true
		g.position.x = pos.x
		g.position.y = pos.y - bg_y_offset
		bg_container.add_child(g)
		grass_list.append(g)
	if fg_container != null:
		var g = grass.instance()
		g.bloomed = false
		g.start_growing = true
		g.position.x = pos.x
		g.position.y = pos.y + fg_y_offset
		fg_container.add_child(g)
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



