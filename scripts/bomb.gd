extends Area2D

const pos_list = [Vector2(0,-100),Vector2(100,0),Vector2(0,100),Vector2(-100,0)]
var bomb_nr = 0
var max_bombs = 0
var source = null
var power = 1

func _ready():
	get_node("AnimationPlayer").play("explode")
	get_node("AnimationPlayer").connect("finished", self, "terminate")
	get_node("damage_timer").connect("timeout", self, "explode")
	get_node("damage_timer").start()
	get_node("next_timer").connect("timeout", self, "continue_chain")
	get_node("next_timer").start()

func configurate(source, bomb_nr, max_bombs, power):
	self.source = source
	self.bomb_nr = bomb_nr
	self.max_bombs = max_bombs
	self.power = power

func continue_chain():
	if bomb_nr >= max_bombs: return
	var next_bomb = self.duplicate(true)
	next_bomb.configurate(source, bomb_nr+1, max_bombs, power)
	next_bomb.set_pos(source.get_pos() + (pos_list[bomb_nr % pos_list.size()] * pow(1.25, int((bomb_nr-1)/4))))
	get_parent().add_child(next_bomb)
	next_bomb.set_owner(get_parent())
	get_node("next_timer").stop()

func explode():
	for body in get_overlapping_bodies():
		"""if body.is_in_group("infected"):
			body.get_node("infection").queue_free()
			var bomb = self.duplicate(true)
			bomb.configurate(source, 0, 0, power)
			bomb.set_pos(body.get_pos())
			get_parent().add_child(bomb)
			bomb.set_owner(get_parent())"""
		if body.is_in_group("enemy"):
			body.set_lives(body.lives - power, source)

func terminate():
	self.queue_free()