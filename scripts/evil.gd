extends KinematicBody2D

var motion = Vector2(-1,0)
var MOTION_SPEED 
var slowed = 0
var lives = 1 setget set_lives
var max_lives = 1
var xp = 1
var name = "evil"

func _ready():
	MOTION_SPEED = randi()%(80 + 2 * get_parent().game_speed) + 70
	while MOTION_SPEED > 250:
		self.lives += 1
		max_lives += 1
		MOTION_SPEED -= 240
		xp += 1
		if is_in_group("boss"):
			var bar = get_node("bar")
			bar.set_max(self.lives)
			bar.set_value(self.lives)
	set_fixed_process(true)
	get_parent().enemies += 1
	get_parent().tot_enemies += 1
	
	name = self.get_name() + " " + str(get_parent().tot_enemies)
	get_parent().freed_list.append(name)

func get_name():
	return "Evil"

func set_direction(x, y, posx, posy):
	motion = Vector2(x, y)
	set_pos(Vector2(posx, posy))

func _fixed_process(delta):
	if is_colliding() and get_collider() and get_collider().is_in_group("Player") and not is_in_group("boss"):
		get_parent().last_touched = get_collider().player_num-1
		set_pos(Vector2(2000, 2000))
	elif is_colliding() and get_collider() and get_collider().is_in_group("wall"):
		motion = -motion
		get_collider().lives -= 1 - (0.5*int(is_in_group("boss")))
	elif is_colliding() and get_collider() and get_collider().is_in_group("bullet"):
		get_collider().hit_enemy(self)
	
	motion = motion.normalized() * MOTION_SPEED * delta
	move(motion)

func set_lives(new_lives, source=null):
	lives = new_lives
	
	if !is_in_group("boss"):
		var colors = ["b62a2a", "62b62a", "b62a75", "5e0000", "0c5e00", "31005e", "241806", "06240a", "24061e"]
		if lives >= colors.size(): 
			lives = colors.size() - 1
		if lives > 0: 
			get_node("Sprite").set_modulate(Color(colors[lives-1]))
	
	if source == null: return
	if lives <= 0:
		if source.killstreak_enabled:
				source.killstreak += 1
				source.coins += (str(source.killstreak).length() -1) * self.xp
		source.xp += self.xp
		self.queue_free()

func set_speed(new_speed):
	MOTION_SPEED = new_speed

func queue_free():
	get_parent().enemies -= 1
	if not get_parent().freed_list.has(name):
		print(name)
		print(get_pos())
	else:
		get_parent().freed_list.remove(get_parent().freed_list.find(name))
	for group in get_groups():
		remove_from_group(group)
	.queue_free()