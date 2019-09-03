extends Panel

var source = null
var multiplier = 0 setget set_multiplier
var price = 50 setget ,get_price
onready var item = get_node("item")
var skills = {\
	"Bomb":{"index":0, 
			"type":"Active ability",
			"icon":"res://sprites/skill icons/bomb.png",
			"info":["Nothing avalible", 
					"One bomb", 
					"Two consecutive bombs with increased power", 
					"Three consecutive bombs with further increased power", 
					"Four consecutive bombs with even further increased power", 
					"Five consecutive bombs with immense power", 
					"Six consecutive bombs with awesome power"],
			"requirements":{"rank points":[0, 0, 0, 0, 1, 2]}},
	"Tower":{"index":0,
			 "type":"Active ability",
			 "icon":"res://sprites/skill icons/tower.png",
			 "info":["No towers", 
					 "One tower", 
					 "Two towers", 
					 "Three towers"],
			 "requirements":{"ranks":[1, 1, 13]}},
	"Fire rate":{"index":0,
				 "type":"Passive boon",
				 "icon":"res://sprites/skill icons/fire rate.png",
				 "info":["Base fire rate", 
						 "Increased fire rate", 
						 "Rapid fire rate", 
						 "Faster fire rate", 
						 "Super fast fire rate!"]},
	"Bullet strength":{"index":0,
					   "type":"Passive boon",
					   "icon":"res://sprites/skill icons/bullet strength.png",
					   "info":["Base bullet strength", 
							   "Base bullet strength +1", 
							   "Base bullet strength +3",
							   "Base bullet strength +6", 
							   "Base bullet strength +10", 
							   "Base bullet strength +15"],
					   "requirements":{"rank points":[0, 0, 1, 1, 1],
									   "ranks":[1, 4, 7, 10, 13]}},
	"Shield":{"index":0,
			  "type":"Passive ability",
			  "icon":"res://sprites/skill icons/shield.png",
			  "info":[  "No shield", 
						"One rotating bullet every 7 seconds", 
						"Two rotating bullets every 7 seconds", 
						"Three rotating bullets every 7 seconds",
						"Four rotating bullets every 7 seconds", 
						"Five rotating bullets every 7 seconds", 
						"Six rotating bullets every 7 seconds", 
						"Seven rotating bullets every 7 seconds", 
						"Eight rotating bullets every 7 seconds"],
			 "requirements":{"ranks":[1, 1, 1, 1, 10, 10, 10, 10]}},
	"Barriers":{"index":0,
			   "type":"Active ability",
			   "icon":"res://sprites/skill icons/barrier.png",
			   "info":["No barriers", 
					   "One barrier", 
					   "Two barriers at the same time", 
					   "Three barriers at the same time"],
			   "requirements":{"ranks":[1, 1, 13]}},
	"Minesweeper":{"index":0,
				   "type":"Active ability",
				   "icon":"res://sprites/skill icons/minesweeper.png",
				   "info":["Not aquired", 
						   "Minesweep surrounding area, receive 25 coins per mine swept", 
						   "Increased minesweeping radius, receive 40 coins per mine swept", 
						   "Large minesweeping radius, receive 50 coins + 0.5% of coins on hand per mine swept"],
			 "requirements":{"ranks":[1, 1, 15],
							 "rank points":[0, 0, 2]}},
	"Spin":{"index":0,
			"type":"Active ability",
			"icon":"res://sprites/skill icons/spin.png",
			"info":["Not aquired", 
					"Shoots a bullet in every direction, and 8 outward rotating bullets", 
					"Shoots two bullets in every direction, and 16 outward rotating bullets"],
			"requirements":{"ranks":[1, 8], 
							"rank points":[0, 1]}},
	"Ghost":{"index":0,
			 "type":"Active ability",
			 "icon":"res://sprites/skill icons/ghost.png",
			 "info":["Not aquired", 
					 "Turn into ghost mode for 2 seconds", 
					 "Turn into ghost mode for 3 seconds", 
					 "Turn into ghost mode for 4 seconds"],
			 "requirements":{"ranks":[5, 5, 8]}},
	"Barrier lives":{"index":0,
					 "type":"Passive boon",
					 "icon":"res://sprites/skill icons/barrier lives.png",
					 "info":["Each barrier has 165 lives", 
							 "Each barrier has 255 lives", 
							 "Each barrier has 420 lives"],
					 "requirements":{"ranks":[3, 7]}},
	"Barrier towers":{"index":0,
					  "type":"Passive boon",
					  "icon":"res://sprites/skill icons/barrier towers.png",
					  "info":["No towers", 
							  "One tower per barrier", 
							  "Two towers per barrier, drops spikes on termination", 
							  "Three towers per barrier, drops more spikes on termination"],
			 		  "requirements":{"ranks":[1, 1, 8]}},
	"Tower bullet strength":{"index":0,
							 "type":"Passive boon",
							 "icon":"res://sprites/skill icons/tower bullet strength.png",
							 "info":["Bullet strength 1", 
									 "Bullet strength 2", 
									 "Bullet strength 3", 
									 "Bullet strength 5", 
									 "Bullet strength 7"],
							 "requirements":{"ranks":[1, 1, 6, 10]}},
	"Tower fire rate":{"index":0,
					   "type":"Passive boon",
					   "icon":"res://sprites/skill icons/tower fire rate.png",
					   "info":["Base fire rate", 
							   "Faster fire rate", 
							   "Superfast firerate"],
					   "requirements":{"ranks":[1, 1, 10]}},
	"Black market":{"index":0,
					"type":"Passive boon",
					"icon":"res://sprites/skill icons/black market.png",
					"info":["Regular income", 
							"Quadruple all income from powerful enemies", 
							"Killstreak income; get more coins for slaying enemies while not taking damage. " + \
							"Receive double coins at 10, triple at 100, quadruple at 1000, and so forth.", 
							"Double all income"],
					"requirements":{"ranks":[8, 12, 17],
									"rank points":[0, 1, 2],
									"fixed prices":[4000, 15000, 30000]}},
   "Gravity disruptor":{"index":0,
						"type":"Active ability",
						"icon":"res://sprites/gravity disruptor.png",
						"info":["Nothing available",
								"A gravitational field that draws enemies to its core",
								"A bigger and stronger gravitational field that lasts longer",
								"An even greater gravitational field, drops a bomb on finish"],
						"requirements":{"rank points":[0, 0, 2]}},
	"Explosive mines":{ "index":0,
						"type":"Active ability",
						"icon":"res://sprites/explosive mine icon.png",
						"info":["Nothing available",
								"drops 4 explosive mines",
								"drops 6 explosive mines",
								"drops 8 explosive mines"],
						"requirements":{"rank points":[0, 0, 1]}},
		 "Infection":{  "index":0,
						"type":"Active special ability",
						"icon":"res://sprites/infection.png",
						"info":["Nothing available",
								"Defiles an area, infecting all enemies which comes near. The infection " +\
								"spreads to other nearby enemies"],
						"requirements":{"rank points":[5]}},
	"Vampiric spirit":{ "index":0,
						"type":"Passive ability",
						"icon":"res://sprites/vampiric spirit.png",
						"info":["Nothing available",
								"Sends out a vampiric spirit in a random direction that " + \
								"steals up to 3 health from enemies. 12 second cooldown",
								"Steals up to 5 health from enemies. 10 second cooldown",
								"Steals up to 7 health from enemies, 8 second cooldown",
								"Steals up to 10 health from enemies, 5 second cooldown"],
						"requirements":{"ranks":[1, 1, 8, 14],
										"rank points":[0, 0, 0, 2]}}
	}

func _ready():
	for skill in get_node("Skills").get_children():
		for button in skill.get_children():
			button.connect("pressed", self, "show_upgrade", [button.get_name()])
	
	for child in get_node("class_interface").get_children():
		if child.get_name().ends_with("button"):
			child.connect("pressed", self, "show_specialization", [child.get_name().split("_")[0]])

func set_source(source):
	self.source = source
	get_node("Player").set_text("Player " +str(source.player_num)) 

func new_rank(rank):
	if rank == 5:
		for button in get_node("class_interface").get_children():
			if button.get_name().ends_with("button"):
				button.set_disabled(false)
				button.set_tooltip("Show " + button.get_name().split("_")[0].to_lower() + " skills")

func upgrade(type, i):
	if !(skills[type].has("requirements") and skills[type]["requirements"].has("fixed prices")):
		self.multiplier += 1
	
	#Fire rate
	if type == "Fire rate":
		source.shooting_rate /= 1.2
	#Bullet strength
	if type == "Bullet strength":
		source.bullet_strength += i
		source.max_bullet_strength += i
	#Shield
	if type == "Shield":
		source.max_rotating_bullets += 1
		if i == 1: source.add_skill("shield")
	#bomb
	if type == "Bomb":
		if i != 1:
			source.max_bombs += 1
			source.skill_list["bomb"]["strength"] += 1 + (3 * int(i / 5))
		if i == 1: source.add_skill("bomb")
	#towers
	if type == "Tower":
		if i != 1:
			source.skill_list["tower"]["charge"] += 1
			source.skill_list["tower"]["cooldown"] /= 2
		if i == 1:
			source.add_skill("tower")
			get_node("Skills/Builder_skills/Tower fire rate").set_disabled(false)
			get_node("Skills/Builder_skills/Tower bullet strength").set_disabled(false)
	#minesweep
	if type == "Minesweeper":
		if i == 1: source.add_skill("minesweep")
		if i == 2: source.minesweeping_xp += 15
		if i == 3: source.minesweeping_xp += 10
	#spin
	if type == "Spin":
		if i == 1: source.add_skill("spin")
		if i == 2: source.can_double_rapid = true
	#ghost
	if type == "Ghost":
		if i == 1: source.add_skill("ghost")
		else: source.ghost_activation_time += 10
	#barrier
	if type == "Barriers":
		source.skill_list["barrier"]["charge"] += 1
		source.max_barriers += 1
		if i == 1:
			source.add_skill("barrier")
			get_node("Skills/Builder_skills/Barrier lives").set_disabled(false)
			get_node("Skills/Builder_skills/Barrier towers").set_disabled(false)
	#barrier lives
	if type == "Barrier lives":
		if i == 1: source.barrier_lives = 255
		elif i == 2: source.barrier_lives = 420
	#barrier towers
	if type == "Barrier towers":
		source.barrier_towers += 1
		get_node("Skills/Builder_skills/Tower fire rate").set_disabled(false)
		get_node("Skills/Builder_skills/Tower bullet strength").set_disabled(false)
	#Black market
	if type == "Black market":
		if i == 1: source.coin_multiplier += 1
		if i == 2: source.killstreak_enabled = true
		if i == 3: source.boss_bonus_enabled = true
	#tower bullet strength
	if type == "Tower bullet strength": source.tower_bullet_strength += 1
	#tower fire rate
	if type == "Tower fire rate": source.tower_fire_rate /= 1.6
	#gravity field
	if type == "Gravity disruptor":
		if i == 1: 
			source.add_skill("gravity disruptor")
		elif i == 2: 
			source.skill_list["gravity disruptor"]["strength"] += 40
			source.skill_list["gravity disruptor"]["scale"] = Vector2(1.8, 1.8)
			source.skill_list["gravity disruptor"]["time active"] += 3
		elif i == 3: 
			source.skill_list["gravity disruptor"]["strength"] += 30
			source.skill_list["gravity disruptor"]["scale"] = Vector2(2.5, 2.5)
			source.skill_list["gravity disruptor"]["drops bomb"] = true
			source.skill_list["gravity disruptor"]["time active"] += 2
	#explosive mines
	if type == "Explosive mines":
		if i == 1: source.add_skill("explosive mines")
		else: source.skill_list["explosive mines"]["number of mines"] += 2
	# Infection
	if type == "Infection":
		source.add_skill("infection")
	# Vampiric spirit
	if type == "Vampiric spirit":
		if i == 1: source.add_skill("vampiric spirit")
		else:
			source.skill_list["vampiric spirit"]["strength"] += 2 + int(i / 4)
			source.skill_list["vampiric spirit"]["cooldown"] -= 2 + int(i / 4)

func get_price():
	return round(price * pow(1.5, multiplier))

func set_multiplier(new_value):
	multiplier = new_value
	item.get_node("Prices/Coins/price").set_text(str(self.price))

func show_upgrade(type):
	get_node("welcome").hide()
	item.show()
	item.configurate(type)

func show_specialization(type):
	for skills in get_node("Skills").get_children():
		skills.hide()
	get_node("Skills/" + type + "_skills").show()