extends "res://scripts/evil.gd"

var target
const evil_scene = preload("res://Levels/evil.tscn")
onready var attack_timer = get_node("Attack_timer")
var can_attack = true

func _ready():
	self.MOTION_SPEED = 35
	set_fixed_process(true)
	attack_timer.connect("timeout", self, "on_attack_timeout")

func _fixed_process(delta):
	motion = Vector2(0,0)
	if target.get_pos().x > get_pos().x:
		motion += Vector2(1, 0)
	if target.get_pos().x < get_pos().x:
		motion += Vector2(-1, 0)
	if target.get_pos().y > get_pos().y:
		motion += Vector2(0, 1)
	if target.get_pos().y < get_pos().y:
		motion += Vector2(0, -1)
	
	if is_colliding() and get_collider() and get_collider().is_in_group("Player"):
		attack()
	#else:
	#	motion = motion.normalized() * MOTION_SPEED * delta
	#	move(motion)

func set_target(new_target):
	self.target = new_target
	self.MOTION_SPEED = 35
	self.MOTION_SPEED += randi() % ((target.lvl / 5) +1)
	lives = 1 + randi() % target.lvl
	max_lives = lives
	get_node("bar").set_max(lives)
	get_node("bar").set_value(lives)
	xp = int(lives * 1.3)

func set_lives(new_lives, source=null):
	lives = new_lives
	if lives > max_lives: lives = max_lives
	get_node("bar").set_value(lives)
	if source == null: return
	if lives <= 0:
		spawn_enemies()
		if source.killstreak_enabled:
				source.killstreak += 1
				source.coins += (str(source.killstreak).length() -1) * self.xp
		source.xp += self.xp
		if source.boss_bonus_enabled: source.xp += self.xp * 3
		self.queue_free()

func spawn_enemies(default_speed=false):
	var liste = [Vector2(-1,0),Vector2(1,0),Vector2(0,1),Vector2(0,-1)]
	for dir in liste:
		var evil = evil_scene.instance()
		evil.set_direction(dir.x, dir.y, get_pos().x, get_pos().y)
		get_parent().add_child(evil)
		evil.set_owner(get_parent())
		if !default_speed: evil.set_speed(evil.MOTION_SPEED / 2)

func attack():
	if can_attack:
		attack_timer.start()
		get_node("AnimationPlayer").play("attack")
		for body in get_node("Area2D").get_overlapping_bodies():
			if body.is_in_group("Player"): body.lives -= 1
		can_attack = false

func get_name():
	return "Boss"

func on_attack_timeout():
	can_attack = true
	attack_timer.stop()