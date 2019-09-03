extends KinematicBody2D

var motion = Vector2(0,0)
var MOTION_SPEED = 999
var strength = 1 setget set_strength
var rotate = false
var circling = true
var clockwise = true
var source = null
var bazooka = false
var pierced = -1
onready var timer = get_node("Timer")

func _ready():
	if source == null: source = get_parent()
	set_fixed_process(true)
	timer.connect("timeout", self, "on_timeout")

func _fixed_process(delta):
	if rotate:
		var p = get_pos()
		if clockwise: motion = Vector2(-p.y, p.x)
		else: motion = Vector2(p.y, -p.x)
		if circling: motion += -get_pos() * 0.035
	
	motion = motion.normalized() * MOTION_SPEED * delta
	move(motion)
	
	if is_colliding():
		hit_enemy(get_collider())

func hit_enemy(body):
	if body.is_in_group("wall"):
			strength = 0
	elif body.is_in_group("enemy"):
		var lives = body.lives
		pierced += 1
		if body.lives <= strength: source.xp += pierced
		body.set_lives(body.lives -strength, source)
		strength -= lives
		if bazooka:
			strength = 0
			var directions = [Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(1,1),
							Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1)]
			for dir in directions:
				var bullet = self.duplicate(true)
				bullet.shoot(dir, get_pos(), source.bullet_strength)
				bullet.set_speed(333)
				get_parent().add_child(bullet)
				bullet.set_owner(get_parent())
				bullet.set_source(source)
	if strength <= 0: queue_free()

func shoot(dir, pos, bullet_strength=1, bazooka=false):
	motion = dir
	set_pos(pos)
	strength = bullet_strength
	self.bazooka = bazooka
	if bazooka: get_node("Sprite").set_modulate("ffffff")

func rotate(bullet_strength, pos=Vector2(0, -110), time=60, circling=true, collision_exception=null):
	strength = bullet_strength
	self.circling = circling
	set_pos(pos)
	rotate = true
	timer.set_wait_time(time)
	timer.start()
	if collision_exception: add_collision_exception_with(collision_exception)

func set_speed(new_speed):
	MOTION_SPEED = new_speed

func on_timeout():
	queue_free()

func set_source(source):
	self.source = source

func set_strength(new_value):
	strength = new_value
	if strength <= 0: queue_free()