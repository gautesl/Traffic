extends Area2D

var source = null
var power = 1 setget set_power
var next_trap = null
var prev_trap = null
var free = false

func _ready():
	connect("body_enter", self, "trigger")
	set_draw_behind_parent(true)
	if source and not free: source.traps += 1

func configurate(source, power, prev, free=false):
	self.source = source
	self.power = power
	self.prev_trap = prev
	if prev: prev_trap.next_trap = self
	self.free = free

func trigger(body):
	if body.is_in_group("enemy"):
		var lives = body.lives
		body.set_lives(body.lives - power, source)
		self.power -= lives

func set_power(new_value):
	power = new_value
	if power <= 0: call_deferred("queue_free")

func queue_free():
	if source.first_trap == self: source.first_trap = next_trap
	if source.last_trap == self: source.last_trap = prev_trap
	if prev_trap: prev_trap.next_trap = next_trap
	if next_trap: next_trap.prev_trap = prev_trap
	
	if not free: source.traps -= 1
	.queue_free()