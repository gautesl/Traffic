extends Area2D

var source = null

func _ready():
	var anim = get_node("AnimationPlayer")
	anim.connect("finished", self, "on_finished")
	anim.play("sweep")
	get_node("sweeper").connect("area_enter", self, "swipe")

func on_finished():
	queue_free()

func set_source(source):
	self.source = source

func swipe(area):
	if area.is_in_group("mine"):
		area.call_deferred("queue_free")
		if source:
			source.xp += source.minesweeping_xp
			if source.minesweeping_xp == 50:
				source.coins += int(source.coins / 200)