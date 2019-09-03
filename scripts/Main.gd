extends Node2D

# Zombie Traffic 2, 2017
# Icons made by Delapouite, sbed and Lorc. Available on http://game-icons.net

var timer
var wait_time = 2

var gametimetimer
var game_speed = 1

var enemies = 0 setget set_enemies
var tot_enemies = 0 setget set_tot_enemies
var items = {}

var gametime = 60 setget set_time
var paused = false setget set_paused
var last_freed = ""
var freed_list = []

const boss_scene = preload("res://Levels/boss.tscn")
const evil_scene = preload("res://Levels/evil.tscn")
const shield_scene = preload("res://Levels/shield.tscn")
const slow_scene = preload("res://Levels/slow.tscn")
const health_scene = preload("res://Levels/health.tscn")
const bazooka_scene = preload("res://Levels/bazooka.tscn")
const treasure_scene = preload("res://Levels/treasure_chest.tscn")
const ship_scene = preload("res://Levels/ship.tscn")
const mine_evil_scene = preload("res://Levels/mine_evil.tscn")
const stronger_bullet_scene = preload("res://Levels/stronger_bullets.tscn")
const blank_scene = preload("res://Levels/blank.tscn")
const mothership_scene = preload("res://Levels/mothership.tscn")

onready var players = [get_node("Player1"), get_node("Player2")]
onready var shop_area = get_node("Shop_area")
var last_touched 
var interface = null
var game_over = false
var intervals = [60]
var mission = 1 setget set_mission
var saved_stats = {}

func _ready():
	timer = Timer.new()
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "spawn_peasant")
	add_child(timer)
	timer.start()
	
	gametimetimer = Timer.new()
	gametimetimer.set_wait_time(1)
	gametimetimer.connect("timeout", self, "on_timeout")
	add_child(gametimetimer)
	gametimetimer.start()
	
	get_node("solution").connect("body_enter", self, "reduce_lives")
	get_node("outside").connect("body_enter", self, "vanquish_evil")
	shop_area.connect("body_enter", self, "enter_shop")
	shop_area.connect("body_exit", self, "exit_shop")
	
	interface = preload("res://Levels/Interface.tscn").instance()
	add_child(interface)
	interface.set_owner(self)
	
	get_tree().set_pause(true)
	for i in range(40):
		intervals.append(intervals[intervals.size()-1] + 20)

func spawn_peasant():
	if paused: return
	"""if mission == 2 and enemies >= 20:
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if not enemy.is_in_group("boss") and not randi() % 20:
				enemy.lives += 1
		return"""
	
	timer.set_wait_time(wait_time)
	if(game_speed < 30):
		wait_time = 0.8 - (game_speed/150)
	else: wait_time = (0.8/(game_speed/20) + 0.1) / players.size()
	
	randomize()
	var peasant
	var target = null
	if randi()% (int(13.0 / (1 + (game_speed/200))) +2):
		peasant = evil_scene.instance()
	elif randi()% 3 and (mission < 7 or randi()% 2):
		peasant = mine_evil_scene.instance()
	elif mission < 2 or randi() % (int(16.0 / (1+((game_speed-120)/200))) +2):
		peasant = boss_scene.instance()
		target = players[randi()% players.size()]
		peasant.set_target(target)
	else:
		if randi() % (40 - int(game_speed/75)): peasant = ship_scene.instance()
		else: peasant = mothership_scene.instance()
		target = players[randi()% players.size()]
		peasant.set_target(target)
	
	var choice = randi()%4
	#1024 600 / 1355 680
	#from left
	if choice == 0:
		peasant.set_direction(1,0, -30, randi()%630)
	#from right
	if choice == 1:
		peasant.set_direction(-1,0, 1384, randi()%630)
	#form bottom
	if choice == 2:
		peasant.set_direction(0,-1, randi()%1305, 710)
	#from top
	if choice == 3:
		peasant.set_direction(0,1, randi()%1305, -30)
	
	add_child(peasant)
	peasant.set_owner(self)

func set_time(new_time):
	gametime = new_time
	interface.get_node("Labels/time").set_text("%02d:%02d" % [int(gametime/60), gametime%60] )

func random_pos():
	return Vector2(randi() % 1200 + 50, randi()% 580 + 50)

func on_timeout():
	if paused: return
	self.gametime -= 1
	game_speed += 1
	if !gametime % 32:
		add_item(stronger_bullet_scene, "stronger_bullets", 5, "increase_bullet_strength")
	if !gametime % 5 and !randi() % 8:
		add_item(shield_scene, "shield", 3, "start_shield", "081195")
	if !gametime % 7 and !randi() % 4:
		add_item(slow_scene, "slow", 5, "start_slow")
	if mission >= 4 and !gametime % 7 and !randi() % 4:
		add_item(bazooka_scene, "bazooka", 3, "start_bazooka", "ffffff")
	if !gametime % 30:
		add_item(treasure_scene, "treasure", 2, "take_treasure")
	if !gametime % 6 and !randi() % 3:
		add_item(health_scene, "health", 7, "add_health")
	if gametime <= 0:
		mission_finished()

func add_item(scene, type, num, funcname, modulate=null):
	var instance = scene.instance()
	instance.set_pos(random_pos())
	instance.connect("body_enter", self, "on_body_enter", [instance, type, funcname])
	if modulate:
		instance.get_node("Sprite").set_modulate(modulate)
	if !items.has(type):
		items[type] = []
	items[type].append(instance)
	if items[type].size() > num:
		items[type][0].queue_free()
		items[type].pop_front()
	add_child(instance)

func remove_item(type):
	if items.has(type) and items[type].size() > 0:
		items[type][0].queue_free()
		items[type].pop_front()
		return true 
	return false

func on_body_enter(body, item, type, funcname):
	if body.is_in_group("Player"):
		if not body.call(funcname):
			items[type].remove(items[type].find(item))
			item.queue_free()

func reduce_lives(body):
	if body.is_in_group("enemy") and body.lives > 0:
		players[last_touched].lives -= max(ceil(body.lives/6), 1)
	body.queue_free()

func vanquish_evil(evil):
	evil.motion = -evil.motion
	if evil.is_in_group("mine") or evil.is_in_group("bullet"):
		if evil.is_in_group("mine"):
			for player in players: player.xp += 10
		evil.queue_free()
	elif evil.is_in_group("Player"):
		evil.set_pos(Vector2(625, 320))

func start_single_player():
	interface.get_node("Skillbar1").show()
	interface.get_node("Skillbar1").set_pos(Vector2(555, 608))
	interface.get_node("Skillbar1").player = players[0]
	players[0].skillbar = interface.get_node("Skillbar1")
	players[0].set_pos(Vector2(625, 320))
	players[1].queue_free()
	players.remove(1)
	players[0].shop = interface.get_node("shop1")
	players[0].shop.set_source(players[0])
	players[0].interface = interface

func start_multiplayer():
	for i in range(players.size()):
		interface.get_node("Skillbar" + str(i+1)).show()
		interface.get_node("Skillbar" + str(i+1)).player = players[i]
		players[i].skillbar = interface.get_node("Skillbar" + str(i+1))
		players[i].shop = interface.get_node("shop"+str(i+1))
		players[i].shop.set_source(players[i])
		players[i].interface = interface

func clear():
	for mine in get_tree().get_nodes_in_group("landmine"):
		mine.queue_free()
	for consumable in get_tree().get_nodes_in_group("consumable"):
		consumable.queue_free()
	for item in get_tree().get_nodes_in_group("removable"):
		item.queue_free()

func mission_finished():
	clear()
	self.paused = true
	for player in players:
		player.lives = player.max_lives
		player.pause(true)
		player.barriers = []
	self.mission += 1

func next_level():
	for player in players:
		if player.preview:
			player.get_node("barrier_shadow").hide()
			player.preview = false
			return
	
	self.paused = false
	items = {}
	self.gametime = intervals[mission]

func set_enemies(new_value):
	enemies = new_value
	interface.get_node("Labels/enemies").set_text(str(enemies))

func enter_shop(body):
	if paused and body.is_in_group("Player"):
		interface.get_node("Labels/Player"+str(body.player_num)+"/can_shop").show()
		body.can_shop = true

func exit_shop(body):
	if body.is_in_group("Player"):
		interface.get_node("Labels/Player"+str(body.player_num)+"/can_shop").hide()
		body.can_shop = false

func set_tot_enemies(new_value):
	tot_enemies = new_value
	interface.get_node("Labels/total_enemies").set_text(str(tot_enemies))

func set_mission(new_value, save=true):
	if save:
		for player in players:
			saved_stats[player] = player.get_stats()
	
	mission = new_value
	if interface: interface.get_node("Labels/mission").set_text("Mission %d" % mission)

func restart():
	if mission == 1: get_tree().reload_current_scene()
	else:
		clear()
		self.paused = true
		self.gametime = 0
		for player in players:
			player.set_stats(saved_stats[player])

func set_paused(new_value):
	paused = new_value
	if paused:
		interface.get_node("Labels/time").set("custom_colors/font_color", "09f017")
		interface.get_node("Labels/mission").set("custom_colors/font_color", "09f017")
		shop_area.show()
		for body in shop_area.get_overlapping_bodies():
			enter_shop(body)
	else:
		interface.get_node("Labels/time").set("custom_colors/font_color", "f00929")
		interface.get_node("Labels/mission").set("custom_colors/font_color", "f00929")
		for player in players:
			player.get_node("barrier_shadow").hide()
			player.preview = false
			player.can_shop = false
			player.shop.hide()
			interface.get_node("Labels/Player"+str(player.player_num)+"/can_shop").hide()
		shop_area.hide()