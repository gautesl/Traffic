extends Area2D

onready var animation = get_node("AnimationPlayer")
var source = null

func _ready():
	animation.connect("finished", self, "explode", [self])
	connect("body_enter", self, "explode")

func configurate(source, skill):
	self.source = source

func explode(body):
	if body.is_in_group("enemy") or body == self:
		var bomb = source.bomb_scene.instance()
		bomb.configurate(source, 0, 0, source.skill_list["bomb"]["strength"])
		bomb.set_pos(get_pos())
		get_parent().add_child(bomb)
		bomb.set_owner(get_parent())
		queue_free()
