extends StaticBody2D

const bullet_scene = preload("res://Levels/bullet.tscn")
onready var shoot_timer = get_node("Shooting_timer")
onready var exp_timer = get_node("Expiration_timer")
var time_left = 100
var bullet_strength = 1
var source = null

func _ready():
	exp_timer.connect("timeout", self, "countdown")
	shoot_timer.connect("timeout", self, "fire")
	exp_timer.start()
	shoot_timer.start()
	get_node("Area2D").connect("body_exit", self, "set_solid")

func countdown():
	time_left -= 1
	get_node("bar").set_value(time_left)
	if time_left <= 0:
		queue_free()

func fire():
	var directions = [Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(1,1),\
				Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1)]
	for dir in directions:
		var bullet = bullet_scene.instance()
		bullet.shoot(dir, get_pos(), bullet_strength)
		bullet.set_speed(333)
		get_parent().add_child(bullet)
		bullet.set_owner(get_parent())
		bullet.set_source(source)

func configurate(source, seconds, pos, strength=1, wait_time=2):
	self.source = source
	time_left = seconds * 10
	get_node("bar").set_max(time_left)
	set_pos(pos)
	bullet_strength = strength
	shoot_timer.set_wait_time(wait_time)
	add_collision_exception_with(source)
	shoot_timer.start()

func set_solid(body):
	if body == source:
		remove_collision_exception_with(source)