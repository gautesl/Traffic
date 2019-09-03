extends Area2D

onready var timer = get_node("Timer")
onready var hp_timer = get_node("HPtimer")
var source = null

func _ready():
	set_fixed_process(true)
	timer.connect("timeout", self, "queue_free")
	timer.start()
	hp_timer.connect("timeout", self, "on_hp_timer")
	hp_timer.start()

func _fixed_process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and not body.is_in_group("infected"):
			body.add_to_group("infected")
			var infection = duplicate(true)
			infection.set_pos(Vector2(0,0))
			infection.set_source(source)
			infection.get_node("Timer").set_wait_time(timer.get_time_left())
			body.add_child(infection)
			infection.set_name("infection")
			infection.set_owner(body)

func on_hp_timer():
	if get_parent().is_in_group("enemy"):
		hp_timer.start()
		get_parent().set_lives(get_parent().lives - max(1, int(get_parent().lives / 20)), source)

func set_source(source):
	self.source = source

func queue_free():
	if get_parent().is_in_group("enemy"):
		get_parent().remove_from_group("infected")
	.queue_free()