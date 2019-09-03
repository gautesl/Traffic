extends "res://scripts/boss.gd"

var boss_scene = preload("res://Levels/boss.tscn")
onready var timer = get_node("Timer")

func _ready():
	MOTION_SPEED = 10
	set_fixed_process(true)
	timer.connect("timeout", self, "spawn_enemies")
	timer.start()

func set_target(new_target):
	self.target = new_target
	lives = max(10 + randi() % (target.lvl*11), 10 + (target.lvl*3))
	get_node("bar").set_max(lives)
	get_node("bar").set_value(lives)
	self.lives = lives
	self.xp = int(lives * 1.3)

func set_lives(new_lives, source=null):
	if new_lives > get_node("bar").value: new_lives = get_node("bar").value
	lives = new_lives
	get_node("bar").set_value(lives)
	get_node("Label").set_text(str(lives))
	if source == null: return
	if lives <= 0:
		var liste = [Vector2(-50,-50),Vector2(-50,50),Vector2(50,-50),Vector2(50,50)]
		for pos in liste:
			var evil = boss_scene.instance()
			evil.set_direction(0, 0, get_pos().x + pos.x, get_pos().y + pos.y)
			evil.set_target(target)
			get_parent().add_child(evil)
			evil.set_owner(get_parent())
		if source.killstreak_enabled:
				source.killstreak += 1
				source.coins += (str(source.killstreak).length() -1) * self.xp
		source.xp += self.xp
		if source.boss_bonus_enabled: source.xp += self.xp * 3
		self.queue_free()

func spawn_enemies(default_speed=false):
	if get_parent().enemies > 300: self.lives += 10
	else: .spawn_enemies(default_speed)

func get_name():
	return "Ship"