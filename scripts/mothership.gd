extends "res://scripts/ship.gd"

var ship_scene = preload("res://Levels/ship.tscn")
var spawn_boss = true

func _ready():
	MOTION_SPEED = 6
	timer.connect("timeout", self, "spawn_boss")
	get_node("bar").set_max(lives*10)
	get_node("bar").value = lives * 10
	self.lives = lives * 10
	self.xp = xp * 10

func spawn_boss():
	spawn_boss = !spawn_boss
	if not spawn_boss: return
	if get_parent().enemies > 300:
		self.lives += 15
		return
	var boss = boss_scene.instance()
	boss.set_target(target)
	boss.set_pos(get_pos())
	get_parent().add_child(boss)
	boss.set_owner(get_parent())

func set_lives(new_value, source=null):
	if new_value <= 0:
		var positions = [Vector2(-75, -75), Vector2(75, -75), Vector2(0, 100)]
		for pos in positions:
			var ship = ship_scene.instance()
			ship.set_target(target)
			get_parent().add_child(ship)
			ship.set_owner(get_parent())
			ship.set_pos(get_pos() + pos)
	.set_lives(new_value, source)

func get_name():
	return "Mothership"