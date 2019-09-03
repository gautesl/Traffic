extends Panel

var info
var index = 0
var max_upgrade
var type = ""
var price = 0
var rank_points = 0
var skill

func _ready():
	get_node("upgrade_button").connect("pressed", self, "upgrade")

func configurate(type):
	skill = get_parent().skills[type]
	self.index = skill["index"]
	self.info = skill["info"]
	self.type = type
	self.max_upgrade = info.size() -1
	
	var sprite = ImageTexture.new()
	sprite.load(skill["icon"])
	sprite.set_size_override(Vector2(75, 75))
	get_node("Sprite").set_texture(sprite)
	
	get_node("Prices").show()
	get_node("Prices/Rank_points").hide()
	get_node("upgrade_button").set_tooltip("")
	get_node("item_title").set_text(type)
	get_node("item_status").set_text("Current: \n" + info[index])
	get_node("item_type").set_text(skill["type"])
	if index != max_upgrade:
		get_node("item_next").set_text("Next: \n" + info[index+1])
		price = get_parent().price
		if skill.has("requirements") and skill["requirements"].has("fixed prices"):
			price = skill["requirements"]["fixed prices"][index]
		get_node("Prices/Coins/price").set_text(str(price))
		
		rank_points = 0
		if skill.has("requirements") and skill["requirements"].has("rank points"):
			rank_points = skill["requirements"]["rank points"][index]
			get_node("Prices/Rank_points").set_hidden(!bool(rank_points))
			get_node("Prices/Rank_points/rank_points").set_text(str(rank_points))
	else:
		get_node("item_next").set_text("Max upgrade reached")
		get_node("upgrade_button").set_tooltip("Max upgrade reached")
		get_node("Prices").hide()
		get_node("upgrade_button").set_disabled(true)
		return
	
	var rank = 1
	if skill.has("requirements") and skill["requirements"].has("ranks"):
		rank = skill["requirements"]["ranks"][index]
	if get_parent().source.lvl < rank:
		get_node("upgrade_button").set_tooltip("Requires rank "+str(rank))
		get_node("upgrade_button").set_disabled(true)
	elif get_parent().source.lvl >= rank and not index == max_upgrade:
		get_node("upgrade_button").set_disabled(false)

func upgrade():
	if get_parent().source.coins < price or index >= max_upgrade \
	or get_parent().source.rank_points < rank_points: return
	get_parent().source.coins -= price
	get_parent().source.rank_points -= rank_points
	index += 1
	skill["index"] = index
	get_parent().upgrade(type, index)
	configurate(type)

func set_avalible(bool_value=true):
	get_node("upgrade_button").set_disabled(!bool_value)
	if bool_value: get_node("upgrade_button").set_tooltip("")