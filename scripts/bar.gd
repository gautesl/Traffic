extends Node2D

export var outer_color = Color()
export var inner_color = Color()
export var min_val = 0
export var max_val = 10
export var value = 10 setget set_value
export var outer_visible = true
var inner
var outer

func _ready():
	inner = get_node("inner")
	outer = get_node("outer")
	outer.set_hidden(!outer_visible)
	inner.set_modulate(inner_color)
	outer.set_modulate(outer_color)

func set_value(new_value):
	value = new_value
	if value < min_val: value = min_val
	if inner: inner.set_scale(Vector2(float(value)/max_val, 1))

func set_max(new_max):
	max_val = new_max

func set_min(new_min):
	min_val = new_min

func set_outer_color(new_color):
	if outer: outer.set_modulate(outer_color)

func set_inner_color(new_color):
	if inner: inner.set_modulate(outer_color)

func set_outer_visible(boolean):
	outer_visible = boolean
	if outer: outer.set_hidden(!outer_visible)
