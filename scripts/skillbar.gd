extends Control

var player = null

func _ready():
	set_process_input(true)

func _input(event):
	if player == null: return
	
	var skills = get_node("Normal skills").get_children() + get_node("Elite skill").get_children()
	for i in range(skills.size()):
		if event.is_action_pressed("ui_skill_" + str(i+1) + "_player_" + str(player.player_num)):
			skills[i].use()

func add_skill(skill):
	if skill["passive"]:
		for node in get_node("Passive skills").get_children():
			node.add_skill(skill)
	elif skill.has("elite") and skill["elite"]:
		get_node("Elite skill").show()
		get_node("Elite skill/Skill4").add_skill(skill)
	else:
		for node in get_node("Normal skills").get_children():
			node.add_skill(skill)

func pause(boolean):
	for control in get_children():
		for node in control.get_children():
			node.get_node("ButtonGroup").hide()
			node.preview = false
			if boolean:
				node.charge = node.current_skill["charge"]
				node.set_opacity(1)
			else: node.set_opacity(0.6)
			if node.get_node("ButtonGroup").get_child_count() == 0: continue
			node.get_node("SelectButton").set_hidden(!boolean)