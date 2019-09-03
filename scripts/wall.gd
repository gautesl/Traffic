extends StaticBody2D

var lives = 165 setget set_lives
onready var sprite = get_node("Sprite")
onready var tower1 = get_node("Tower1")
onready var tower2 = get_node("Tower2")
onready var tower3 = get_node("Tower3")
onready var timer = get_node("Shoot_timer")
onready var tower_list = [tower1, tower2, tower3]
var spikes = 0
var towers = 0
var source = null
const bullet_scene = preload("res://Levels/bullet.tscn")
const trap_scene = preload("res://Levels/trap.tscn")
var directions = [Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),\
				  Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(1,-1)]

func _ready():
	get_node("Area2D").connect("body_exit", self, "set_solid")
	timer.connect("timeout", self, "shoot")

func set_lives(new_value):
	lives = new_value
	
	if lives > 326: sprite.set_modulate(Color(1, float(416 + (lives-326)) / 510, 0 / 255, 255))
	elif lives > 255: sprite.set_modulate(Color(1, float(lives - 255 + 137) / 255, 0 / 255, 255))
	else: sprite.set_modulate(Color(float(lives) / 255, float(lives) / 550, 0 / 255, 255))
	if lives <= 0:
		for i in range(spikes):
			var trap = trap_scene.instance()
			trap.configurate(source, source.bullet_strength, null, true)
			trap.set_pos(get_node("Points/Node2D"+str(i+1)).get_global_pos())
			get_parent().add_child(trap)
			trap.set_owner(get_parent())
		for i in range(source.barriers.size()):
			if source.barriers[i] == self: source.barriers.remove(i)
		queue_free()

func set_solid(body):
	if body == source:
		remove_collision_exception_with(source)

func configurate(lives, towers, fire_rate=0.5):
	self.lives = lives
	self.towers = towers
	if towers >= 1:
		tower1.show()
		timer.start()
	if towers == 2:
		tower1.set_pos(Vector2(-10, 0))
		tower2.show()
		tower2.set_pos(Vector2(10, 0))
		self.spikes = 5
	elif towers == 3:
		tower2.set_pos(Vector2(-20, 0))
		tower2.show()
		tower3.set_pos(Vector2(20, 0))
		tower3.show()
		self.spikes = 10
	get_node("Shoot_timer").set_wait_time(0.5 * (fire_rate / 2))

func set_source(source):
	self.source = source

func shoot():
	for i in range(towers):
		var bullet = bullet_scene.instance()
		bullet.shoot(directions[int(get_rotd()/45)], tower_list[i].get_global_pos(), source.tower_bullet_strength)
		bullet.set_speed(333)
		get_parent().add_child(bullet)
		bullet.set_owner(get_parent())
		bullet.set_source(source)