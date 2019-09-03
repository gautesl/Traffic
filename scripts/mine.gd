extends Area2D

var slow = false

func _ready():
	connect("body_enter", self, "enter_mine")
	if ! randi() % 7:
		slow = true
		get_node("Sprite").set_texture(load("res://sprites/player_slow.png"))

func enter_mine(body):
	if body.is_in_group("Player") and not body.ghost_timer.get_time_left():
		if slow: body.self_slow_timer.start()
		else: body.lives -= 1
		queue_free()