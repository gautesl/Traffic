extends KinematicBody2D

var source = null
var direction = Vector2(0, -1)
const MOTION_SPEED = 250
var strength = 3

func _ready():
	set_fixed_process(true)
	get_node("Timer").connect("timeout", self, "queue_free")

func _fixed_process(delta):
	move(direction * MOTION_SPEED * delta)
	if is_colliding():
		handle_collision(get_collider())

func handle_collision(body):
	if body.is_in_group("wall"):
		queue_free()
	if body.is_in_group("enemy"):
		var lives = body.lives
		if lives <= strength:
			source.xp += lives
			source.lives += lives
		else: source.lives += strength
		body.set_lives(lives - strength, source)
		strength -= lives
	if strength <= 0: queue_free()

func configurate(source, skill):
	self.source = source
	strength = skill["strength"]
	var enemies = get_tree().get_nodes_in_group("enemy")
	if not enemies.empty():
		var target_pos = enemies[randi() % enemies.size()].get_pos()
		direction = (target_pos - get_pos()).normalized()
		look_at(target_pos)