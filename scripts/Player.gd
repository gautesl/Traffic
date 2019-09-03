extends KinematicBody2D

var motion
var MOTION_SPEED = 142 
var bonus_speed = 1
var rot
var can_shoot = true
var can_double_rapid = false
var can_shop = false
var shooting_rate = 2 setget set_shooting_rate
var preview = false
var shop = null
var interface = null
var skillbar = null
var killstreak_enabled = false
var killstreak = 0
var boss_bonus_enabled = false
var minesweeping_xp = 25
var tower_bullet_strength = 1
var tower_fire_rate = 2
var rank_points = 0 setget set_rank_points
onready var shoot_timer = get_node("Timers/shoot_timer")
onready var bullet_strength_timer = get_node("Timers/bullet_strength_timer")
onready var rotate_timer = get_node("Timers/rotate_timer")
onready var rapid_timer = get_node("Timers/rapid_timer")
onready var bazooka_timer = get_node("Timers/bazooka_timer")
onready var ghost_timer = get_node("Timers/ghost_timer")
onready var self_slow_timer = get_node("Timers/self_slow_timer")

const bullet_scene = preload("res://Levels/bullet.tscn")
const minesweeper_scene = preload("res://Levels/minesweeper.tscn")
const tower_scene = preload("res://Levels/tower.tscn")
const barrier_scene = preload("res://Levels/wall.tscn")
const bomb_scene = preload("res://Levels/bomb.tscn")
const trap_scene = preload("res://Levels/trap.tscn")
const gravity_disruptor_scene = preload("res://Levels/gravity_field.tscn")
const explosive_mine_scene = preload("res://Levels/explosive_mine.tscn")
const infection_scene = preload("res://Levels/Infection.tscn")
const vampire_scene = preload("res://Levels/vampiric_spirit.tscn")

var lives = 3 setget set_lives
var weapon_nr = 0 setget set_weapon_nr
var bullet_strength = 1 setget set_bullet_strength
var max_bullet_strength = 1
var max_rotating_bullets = 0
var max_bombs = 0
var barriers = []
var max_barriers = 0
var barrier_lives = 165
var barrier_towers = 0 setget set_barrier_towers
var traps = 0
var max_traps = 0
var ghost_activation_time = 20
var first_trap = null
var last_trap = null
var bazooka_mode = false
var rotate_cd = 70
var rapid_cd = 6
var ghost_cd = 275

export var player_num = 1
export var color = Color()

var weapons = ["Bullets"]
var coins = 0 setget set_coins
var xp_list = [0, 10]
var lvl = 0 setget set_lvl
var xp = 0 setget set_xp
var max_lives = 2
var bazooka_shots = 0
var slowing = false
var coin_multiplier = 0
onready var bullet_strength_anim = get_node("Animations/bullet_strength_active")
onready var slow_active_anim = get_node("Animations/slow_active")

var skill_list = {"bomb":  {"name":"Bomb", 
							"cooldown":15,
							"charge":1,
							"passive":false,
							"preview":null,
							"funcref":funcref(self, "start_bomb_chain"), 
							"icon":"res://sprites/skill icons/bomb.png", 
							"strength":1},
			   "minesweep":{"name":"Minesweep",
							"cooldown":20,
							"charge":1,
							"passive":false,
							"preview":null,
							"funcref":funcref(self, "minesweep"),
							"icon":"res://sprites/skill icons/minesweeper.png"},
				"spin":    {"name":"Spin", 
							"cooldown":10,
							"charge":1,
							"passive":false,
							"preview":null,
							"funcref":funcref(self, "fire_rapid"),
							"icon":"res://sprites/skill icons/spin.png"},
				"ghost":   {"name":"Ghost",
							"cooldown":14,
							"charge":1,
							"passive":false,
							"preview":null,
							"funcref":funcref(self, "ghost_mode"),
							"icon":"res://sprites/skill icons/ghost.png"},
				"tower":   {"name":"Tower",
							"cooldown":10,
							"charge":1,
							"passive":false,
							"preview":null,
							"funcref":funcref(self, "place_tower"),
							"icon":"res://sprites/skill icons/tower.png"},
				"barrier": {"name":"Barrier",
							"cooldown":45,
							"charge":0,
							"passive":false,
							"preview":funcref(self, "preview_barrier"),
							"funcref":funcref(self, "place_barrier"),
							"icon":"res://sprites/skill icons/barrier.png"},
				"shield": {"name":"Shield",
							"cooldown":7,
							"charge":1,
							"passive":true, 
							"preview":null,
							"funcref":funcref(self, "fire_passive_rotating"),
							"icon":"res://sprites/skill icons/shield.png"},
	  "gravity disruptor": {"name":"Gravity disruptor",
							"cooldown":14,
							"charge":1,
							"passive":false, 
							"preview":null,
							"funcref":funcref(self, "place_gravity_disruptor"),
							"icon":"res://sprites/skill icons/gravity disruptor.png",
							"strength":100,
							"drops bomb":false,
							"scale":Vector2(1, 1),
							"time active":7},
		"explosive mines": {"name":"Explosive mines",
							"cooldown":17,
							"charge":1,
							"passive":false, 
							"preview":null,
							"funcref":funcref(self, "place_explosive_mine"),
							"icon":"res://sprites/skill icons/explosive mine icon.png",
							"number of mines":4,
							"mines placed":0},
			  "infection": {"name":"Infection",
							"elite":true,
							"cooldown":30,
							"charge":1,
							"passive":false,
							"preview":null,
							"funcref":funcref(self, "start_infection"),
							"icon":"res://sprites/skill icons/infection.png"},
		"vampiric spirit": {"name":"Vampiric spirit",
							"cooldown":12,
							"charge":1,
							"passive":true,
							"preview":null,
							"funcref":funcref(self, "emit_vampires"),
							"icon":"res://sprites/skill icons/vampiric spirit.png",
							"strength":3}
}

func get_stats():
	return {"Attributes":[lvl, xp, coins, bullet_strength, max_bullet_strength, \
						  shooting_rate, null, rank_points, lives, max_lives], \
			"Skills":[null, minesweeping_xp, \
					  null, can_double_rapid, \
					  null, max_bombs, null, ghost_activation_time, \
					  null, tower_bullet_strength, tower_fire_rate, \
					  max_barriers, barrier_lives, barrier_towers, \
					  max_traps, max_rotating_bullets], 
			"Economy":[coin_multiplier, boss_bonus_enabled, killstreak_enabled, killstreak], 
			"Shop":[shop.skills]}

func set_stats(stats):
	var stat = stats["Attributes"]
	self.lvl = stat[0]
	self.xp = stat[1]
	self.coins = stat[2]
	self.bullet_strength = stat[3]
	self.max_bullet_strength = stat[4]
	self.shooting_rate = stat[5]
	self.rank_points = stat[7]
	get_node("Bars/Health").set_max(stat[9])
	max_lives = stat[9]
	self.lives = stat[8]
	get_node("Bars/Health").set_value(lives)
	stat = stats["Skills"]
	self.minesweeping_xp = stat[1]
	self.can_double_rapid = stat[3]
	self.max_bombs = stat[5]
	self.ghost_activation_time = stat[7]
	self.tower_bullet_strength = stat[9]
	self.tower_fire_rate = stat[10]
	self.max_barriers = stat[11]
	self.barrier_lives = stat[12]
	self.barrier_towers = stat[13]
	self.max_traps = stat[14]
	self.max_rotating_bullets = stat[15]
	stat = stats["Economy"]
	self.coin_multiplier = stat[0]
	self.boss_bonus_enabled = stat[1]
	self.killstreak_enabled = stat[2]
	self.killstreak = stat[3]
	stat = stats["Shop"]
	shop.skills = stat[0]
	barriers = []
	traps = 0

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	for i in range(70):
		xp_list.append(int(xp_list[i+1] * 1.6))
	
	get_node("Sprite").set_modulate(color)
	shoot_timer.connect("timeout", self, "reload")
	bullet_strength_timer.connect("timeout", self, "on_bullet_strength_timeout")
	rapid_timer.connect("timeout", self, "on_rapid_timeout")
	bazooka_timer.connect("timeout", self, "on_bazooka_timeout")
	ghost_timer.connect("timeout", self, "on_ghost_timeout")
	get_node("Slow_range").connect("body_enter", self, "slow_enemy")
	get_node("Slow_range").connect("body_exit", self, "speed_enemy")
	get_node("Slow_range/Timer").connect("timeout", self, "end_slow")
	
	self.xp = 0
	shoot_timer.start()

func _fixed_process(delta):
	motion = Vector2()
	
	if(Input.is_action_pressed("ui_"+str(player_num)+"_up")):
		motion += Vector2(0, -1)
		
	if(Input.is_action_pressed("ui_"+str(player_num)+"_left")):
		motion += Vector2(-1, 0)
		
	if(Input.is_action_pressed("ui_"+str(player_num)+"_down")):
		motion += Vector2(0, 1)
		
	if(Input.is_action_pressed("ui_"+str(player_num)+"_right")):
		motion += Vector2(1, 0)
	
	if is_colliding() and get_collider() and get_collider().is_in_group("enemy") \
										and not get_collider().is_in_group("boss"):
			get_parent().last_touched = player_num -1
			get_collider().set_pos(Vector2(2000, 2000))
	
	motion = motion.normalized() * (MOTION_SPEED + min(get_parent().game_speed, 200)) * delta * bonus_speed
	if self_slow_timer.get_time_left() and not ghost_timer.get_time_left(): 
		motion /= 3.4
	move(motion)
	
	#barrier
	if get_node("barrier_shadow").get_overlapping_bodies().size() == 1:
		get_node("barrier_shadow/Sprite").set_modulate("4a55ff")
	else: get_node("barrier_shadow/Sprite").set_modulate("ef2424")

func _input(event):
	if event.is_action_pressed("ui_rotate_" + str(player_num)):
		if preview:
			get_node("barrier_shadow").set_rotd(int(get_node("barrier_shadow").get_rotd() + 45) % 360)
	if event.is_action_pressed("ui_switch_"+str(player_num)):
		self.weapon_nr += 1
	if event.is_action_pressed("ui_cheat"):
		self.xp += xp_list[lvl]
		self.coins += 5000
		get_parent().gametime -= 30
	if event.is_action_pressed("ui_next") and get_parent().paused:
		get_parent().next_level()
		pause(false)
	if event.is_action_pressed("ui_shop_"+str(player_num)) and can_shop:
		shop.set_hidden(!shop.is_hidden())
		shop.get_node("item").set_hidden(true)
		shop.get_node("welcome").set_hidden(false)

func set_lives(new_lives):
	if lives > new_lives: self.killstreak = 0
	if new_lives > max_lives: new_lives = max_lives
	lives = new_lives
	get_node("Label").set_text(str(lives))
	var lifestring = ""
	var templives = lives
	while templives >= 5:
		templives -= 5
		lifestring += "+ "
	
	for i in range(templives):
		lifestring += "O " 
	
	get_parent().interface.get_node("Labels/Player"+str(player_num)+"/lives").set_text(lifestring)
	get_node("Bars/Health").set_value(lives)
	
	if lives <= 0:
		get_tree().set_pause(true)
		get_parent().game_over = true

func shoot():
	var liste = [Vector2(-1,0),Vector2(1,0),Vector2(0,1),Vector2(0,-1)]
	if weapons[weapon_nr] == "Mines":
		var trap = trap_scene.instance()
		trap.configurate(self, bullet_strength, last_trap)
		trap.set_pos(get_pos())
		last_trap = trap
		if !first_trap: first_trap = trap
		get_parent().add_child(trap)
		trap.set_owner(get_parent())
		if traps > max_traps: first_trap.queue_free()
	if weapons[weapon_nr] == "Bullets":
		for i in range(4):
			var bullet = bullet_scene.instance()
			bullet.shoot(liste[i], get_pos(), bullet_strength, bazooka_mode)
			get_parent().add_child(bullet)
			bullet.set_owner(get_parent())
			bullet.set_source(self)
	can_shoot = false
	shoot_timer.start()

func reload():
	shoot_timer.set_wait_time(shooting_rate)
	can_shoot = true
	shoot()

func set_xp(new_xp):
	self.coins += new_xp - xp
	xp = new_xp
	if xp >= xp_list[lvl]:
		self.lvl += 1
		xp -= xp_list[lvl -1]
		if !(xp == 0 and lvl == 1): get_parent().interface.get_node("Bars/xp_bar" + str(player_num)).set_max(xp_list[lvl])
	if !(xp == 0 and lvl == 1): get_parent().interface.get_node("Bars/xp_bar" + str(player_num)).set_value(xp)

func set_lvl(new_lvl):
	lvl = new_lvl
	max_lives += 1
	get_node("Bars/Health").set_max(max_lives)
	if lvl != 1:
		shop.new_rank(lvl)
		self.shooting_rate *= (0.89 + (sqrt(lvl) / 70))
		self.lives += 1
		get_parent().interface.get_node("Labels/Player"+str(player_num)+"/lvl").set_text("Rank: " + str(lvl))
	max_traps += 1
	self.rank_points += 1
	#if lvl == 4: weapons.append("Mines")


func slow_enemy(body):
	if body.is_in_group("enemy") and slowing:
		body.slowed += 1
		if body.slowed == 1: body.MOTION_SPEED /= 2

func speed_enemy(body):
	if body.is_in_group("enemy") and body.slowed >= 1 and slowing:
		body.slowed -= 1
		if not body.slowed: body.MOTION_SPEED *= 2

func start_slow():
	slow_active_anim.play("slow_active")
	get_node("Slow_range/Timer").start()
	slowing = true
	for body in get_node("Slow_range").get_overlapping_bodies():
		if !body.is_in_group("enemy"): continue
		body.slowed += 1
		if body.slowed == 1: body.MOTION_SPEED /= 2

func end_slow():
	slowing = false
	slow_active_anim.stop()
	get_node("Slow_range").hide()
	for body in get_node("Slow_range").get_overlapping_bodies():
		if !body.is_in_group("enemy"): continue
		body.slowed -= 1
		if not body.slowed: body.MOTION_SPEED *= 2

func increase_bullet_strength():
	bullet_strength_timer.set_wait_time(6 + lvl / 4)
	bullet_strength_timer.start()
	bullet_strength_anim.play("bullet_strength_active")
	self.bullet_strength += int(lvl / 2) +1

func on_bullet_strength_timeout():
	self.bullet_strength = max_bullet_strength
	bullet_strength_anim.stop()
	bullet_strength_timer.stop()
	get_node("Sprite").set_modulate(color)

func set_weapon_nr(new_value):
	weapon_nr = new_value % weapons.size()
	get_parent().interface.get_node("Labels/Player"+str(player_num)+"/weapon").set_text(weapons[weapon_nr])

func minesweep():
	var minesweeper = minesweeper_scene.instance()
	minesweeper.set_source(self)
	minesweeper.set_pos(get_pos())
	if minesweeping_xp == 40: minesweeper.set_scale(Vector2(2, 2))
	if minesweeping_xp == 50: minesweeper.set_scale(Vector2(2.5, 3))
	get_parent().add_child(minesweeper)

func fire_passive_rotating():
	var list = [Vector2(0,-110), Vector2(110,0),Vector2(0,110),Vector2(-110,0),\
				Vector2(0,-150), Vector2(150,0),Vector2(0,150),Vector2(-150,0)]
	for i in range(max_rotating_bullets):
		shoot_rotating(lvl + (bullet_strength*2), list[i % list.size()], 8)

func shoot_rotating(strength, pos=Vector2(0, -110), time=60):
	var bullet = bullet_scene.instance()
	bullet.set_speed(333)
	add_child(bullet)
	bullet.set_owner(self)
	bullet.rotate(strength, pos, time, true, get_node("../ground"))

func start_shield():
	var list = [Vector2(-110, 0), Vector2(0, -110), Vector2(110, 0), Vector2(0, 110)]
	for pos in list:
		shoot_rotating(3 + bullet_strength, pos, 15)

func fire_rapid(clockwise=true):
	var directions = [Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(1,1),\
				Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1)]
	for dir in directions:
		var bullet1 = bullet_scene.instance()
		var bullet2 = bullet_scene.instance()
		bullet1.shoot(dir, get_pos(), bullet_strength)
		bullet1.set_speed(333)
		get_parent().add_child(bullet1)
		bullet1.set_owner(get_parent())
		bullet1.set_source(self)
		add_child(bullet2)
		bullet2.set_owner(get_parent())
		bullet2.set_source(self)
		bullet2.rotate(bullet_strength, dir, 20, false)
		bullet2.clockwise = clockwise
	if can_double_rapid:
		rapid_cd = 6
		rapid_timer.start()

func on_rapid_timeout():
	rapid_cd -= 1
	if rapid_cd <= 0:
		fire_rapid(false)
		rapid_timer.stop()

func place_tower():
	var tower = tower_scene.instance()
	get_parent().add_child(tower)
	tower.set_owner(get_parent())
	tower.configurate(self, 6 + (float(lvl) / 10), get_pos(), tower_bullet_strength, tower_fire_rate)

func start_bazooka():
	bazooka_mode = true
	bazooka_timer.set_wait_time(1 + (lvl / 8.5))
	bazooka_timer.start()

func on_bazooka_timeout():
	bazooka_timer.stop()
	bazooka_mode = false

func place_barrier():
	if get_node("barrier_shadow").get_overlapping_bodies().size() > 1: return -1
	var barrier = barrier_scene.instance()
	get_parent().add_child(barrier)
	barrier.set_owner(get_parent())
	barrier.add_collision_exception_with(self)
	barrier.set_source(self)
	barrier.set_pos(get_pos())
	barrier.set_rotd(get_node("barrier_shadow").get_rotd())
	barrier.configurate(barrier_lives, barrier_towers, tower_fire_rate)
	barriers.append(barrier)
	preview = false
	get_node("barrier_shadow").hide()
	if barriers.size() > max_barriers:
		barriers[0].queue_free()
		barriers.pop_front()

func preview_barrier():
	get_node("barrier_shadow").show()
	preview = true

func start_bomb_chain():
	var bomb = bomb_scene.instance()
	bomb.configurate(self, 0, max_bombs, max(int((lvl-8) / 8), 1))
	bomb.set_pos(get_pos())
	get_parent().add_child(bomb)
	bomb.set_owner(get_parent())

func place_gravity_disruptor():
	var field = gravity_disruptor_scene.instance()
	field.set_pos(get_pos())
	get_parent().add_child(field)
	field.configurate(self, skill_list["gravity disruptor"])
	field.set_owner(get_parent())

func place_explosive_mine():
	skill_list["explosive mines"]["mines placed"] += 1
	var mine = explosive_mine_scene.instance()
	mine.configurate(self, skill_list["explosive mines"])
	mine.set_pos(get_pos())
	get_parent().add_child(mine)
	mine.set_owner(get_parent())
	
	if skill_list["explosive mines"]["mines placed"] == skill_list["explosive mines"]["number of mines"]:
		skill_list["explosive mines"]["mines placed"] = 0
		return
	
	var timer = Timer.new()
	timer.set_wait_time(0.7)
	timer.connect("timeout", timer, "queue_free")
	timer.connect("timeout", self, "place_explosive_mine")
	add_child(timer)
	timer.start()

func start_infection():
	var infection = infection_scene.instance()
	infection.set_source(self)
	infection.set_pos(get_pos())
	get_parent().add_child(infection)
	infection.set_owner(get_parent())

func ghost_mode():
	set_opacity(0.4)
	get_node("CollisionShape2D").set_trigger(true)
	bonus_speed = 1.7
	ghost_cd = ghost_activation_time
	ghost_timer.start()

func on_ghost_timeout():
	ghost_cd -= 1
	if ghost_cd == 0:
		get_node("CollisionShape2D").set_trigger(false)
		set_opacity(1)
		bonus_speed = 1
		ghost_timer.stop()

func emit_vampires():
	var vampire = vampire_scene.instance()
	vampire.set_pos(get_pos())
	get_parent().add_child(vampire)
	vampire.set_owner(get_parent())
	vampire.configurate(self, skill_list["vampiric spirit"])

func add_health():
	if lives >= max_lives: return -1
	self.lives += floor(max_lives / 5) + 1

func take_treasure():
	self.xp += round(self.coins / 10)

func set_coins(new_value):
	var surplus = new_value - coins
	coins = new_value
	if surplus > 0: coins += surplus * coin_multiplier
	if interface: interface.get_node("Labels/Player"+str(player_num)+"/coins").set_text(str(coins))
	if shop: shop.get_node("coins").set_text("Coins: " + str(coins))

func set_barrier_towers(new_value):
	barrier_towers = new_value
	if barrier_towers == 0:
		get_node("barrier_shadow/Sprite/Tower1").hide()
		get_node("barrier_shadow/Sprite/Tower2").hide()
		get_node("barrier_shadow/Sprite/Tower3").hide()
	elif barrier_towers == 1:
		get_node("barrier_shadow/Sprite/Tower1").set_pos(Vector2(0,0))
		get_node("barrier_shadow/Sprite/Tower1").show()
		get_node("barrier_shadow/Sprite/Tower2").hide()
		get_node("barrier_shadow/Sprite/Tower3").hide()
	elif barrier_towers == 2:
		get_node("barrier_shadow/Sprite/Tower1").set_pos(Vector2(-70,0))
		get_node("barrier_shadow/Sprite/Tower2").show()
		get_node("barrier_shadow/Sprite/Tower2").set_pos(Vector2(70,0))
		get_node("barrier_shadow/Sprite/Tower3").hide()
	elif barrier_towers == 3:
		get_node("barrier_shadow/Sprite/Tower1").set_pos(Vector2(0,0))
		get_node("barrier_shadow/Sprite/Tower2").set_pos(Vector2(-140,0))
		get_node("barrier_shadow/Sprite/Tower3").set_pos(Vector2(140,0))
		get_node("barrier_shadow/Sprite/Tower3").show()

func set_bullet_strength(new_value):
	bullet_strength = new_value
	if get_parent().interface: get_parent().interface.get_node("Labels/Player"+str(player_num)+\
	"/bullet_strength").set_text("Bullet strength: " + str(bullet_strength))

func set_shooting_rate(new_value):
	shooting_rate = new_value
	if get_parent().interface: get_parent().interface.get_node("Labels/Player"+str(player_num)+\
	"/fire_rate").set_text("Fire rate: %.3f" % shooting_rate)

func set_rank_points(new_value):
	rank_points = new_value
	if shop: shop.get_node("rank_points").set_text("Rank points: "+str(rank_points))

func add_skill(skill_name):
	skillbar.add_skill(skill_list[skill_name])

func pause(boolean):
	skillbar.pause(boolean)