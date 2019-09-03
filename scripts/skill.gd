extends Panel

export var key_nr = '1'
export var sprite = preload("res://sprites/no_skill.png")

onready var default_skill = {"name":"default skill", 
							 "cooldown":0, 
							 "charge":1, 
							 "passive":false,
							 "preview":null,
							 "funcref":null, 
							 "icon":"res://sprites/no_skill.png"}
onready var current_skill = default_skill
onready var timer = get_node("Timer")
var can_use = true
var preview = false

var charge = 1 setget set_charge
var time_left = 10 setget set_time

func _ready():
	self.time_left = current_skill["cooldown"]
	get_node("SelectButton").connect("button_down", self, "select_pressed")
	timer.connect("timeout", self, "on_timeout")

func use():
	if can_use:
		if not preview and current_skill["preview"]:
			current_skill["preview"].call_func()
			preview = true
		elif current_skill["funcref"] and not current_skill["funcref"].call_func():
			if charge == current_skill["charge"]:
				self.time_left = current_skill["cooldown"] * 10
			self.charge -= 1
			timer.start()
			if current_skill["preview"]: preview = false

func on_timeout():
	self.time_left -= 1
	if time_left <= 0:
		self.charge += 1
		if charge >= current_skill["charge"]: timer.stop()
		else: self.time_left = current_skill["cooldown"] * 10
		if current_skill["passive"]: use()

func select_pressed():
	for node in get_parent().get_children():
		if node != self: node.get_node("ButtonGroup").hide()
	get_node("ButtonGroup").set_hidden(!get_node("ButtonGroup").is_hidden())

func add_skill(skill):
	var button = Button.new()
	button.set_text(skill["name"])
	var sprite = ImageTexture.new()
	sprite.load(skill["icon"])
	sprite.set_size_override(Vector2(20, 20))
	button.set_button_icon(sprite)
	button.connect("pressed", self, "change_skill", [skill])
	get_node("ButtonGroup").add_child(button)
	get_node("ButtonGroup").set_pos(get_node("ButtonGroup").get_pos() - Vector2(0, 26))
	get_node("SelectButton").show()

func change_skill(skill):
	if not skill == default_skill:
		for node in get_parent().get_children():
			if node.current_skill == skill:
				node.change_skill(default_skill)
	
	current_skill = skill
	var new_sprite = ImageTexture.new()
	new_sprite.load(skill["icon"])
	new_sprite.set_size_override(Vector2(75, 75))
	get_node("Sprite").set_texture(new_sprite)
	get_node("ButtonGroup").hide()
	self.charge = current_skill["charge"]
	if current_skill["passive"]: use()

func set_time(new_value):
	var cooldown = max(current_skill["cooldown"] * 10, 0.00001)
	if new_value > cooldown: new_value = cooldown
	if new_value < 0: new_value = 0
	time_left = new_value
	get_node("Shadow").set_pos(Vector2(1.25, 1.25 + (37.5 * ((cooldown - time_left) / cooldown))))
	get_node("Shadow").set_scale(Vector2(0.75, 0.75 * (float(time_left) / cooldown)))
	get_node("Charge/Shadow").set_pos(Vector2(40 * ((cooldown - time_left) / cooldown), 0))
	get_node("Charge/Shadow").set_scale(Vector2(0.8 * (float(time_left) / cooldown), 0.18))
	get_node("Key_nr").set_text(key_nr)
	get_node("Cooldown").set_text(str(floor(time_left / 10) + 1))

func set_charge(new_value):
	if new_value < 0: new_value = 0
	if new_value > current_skill["charge"]: new_value = current_skill["charge"]
	charge = new_value
	
	if current_skill["charge"] <= 1: get_node("Charge").hide()
	else: get_node("Charge").show()
	get_node("Charge/Label").set_text(str(charge))
	
	if charge <= 0:
		get_node("Shadow").show()
		get_node("Cooldown").show()
		can_use = false
	else:
		get_node("Shadow").hide()
		get_node("Cooldown").hide()
		can_use = true