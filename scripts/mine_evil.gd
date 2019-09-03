extends "res://scripts/evil.gd"

const mine_scene = preload("res://Levels/mine.tscn")

func _ready():
	MOTION_SPEED = 150
	lives = 1

func set_lives(new_lives, source=null):
	lives = new_lives
	if lives > 1: lives = 1
	if lives <= 0:
		if !get_parent().paused:
			var mine = mine_scene.instance()
			mine.set_pos(get_pos())
			get_parent().add_child(mine)
			mine.set_owner(get_parent())
		self.queue_free()

func get_name():
	return "Mine evil"