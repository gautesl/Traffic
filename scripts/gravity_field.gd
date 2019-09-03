extends Area2D

var motion_speed = 100
var source = null
var drops_bomb = false
onready var timer = get_node("Timer")

func _ready():
	set_fixed_process(true)
	timer.connect("timeout", self, "queue_free")

func _fixed_process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.move((get_pos() - body.get_pos()).normalized() * motion_speed * delta)

func configurate(source, skill):
	self.source = source
	self.motion_speed = skill["strength"]
	set_scale(skill["scale"])
	drops_bomb = skill["drops bomb"]
	timer.set_wait_time(skill["time active"])
	timer.start()

func queue_free():
	if drops_bomb:
		var bomb = source.bomb_scene.instance()
		bomb.configurate(source, 0, 0, source.skill_list["bomb"]["strength"] * 3)
		bomb.set_pos(get_pos())
		get_parent().add_child(bomb)
		bomb.set_owner(get_parent())
	.queue_free()