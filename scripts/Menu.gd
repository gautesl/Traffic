extends CanvasLayer

onready var main_menu = get_node("Main Menu")

func _ready():
	main_menu.get_node("single_button").connect("pressed", self, "start_single_player")
	main_menu.get_node("multi_button").connect("pressed", self, "start_multiplayer")
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_pause"):
		if get_tree().is_paused():
			if get_parent().game_over:
				get_parent().game_over = false
				get_parent().restart()
			get_tree().set_pause(false)
		else: get_tree().set_pause(true)

func start_single_player():
	get_parent().start_single_player()
	start_game()
	get_node("Labels/Player2").hide()
	get_node("Bars/xp_bar2").hide()

func start_multiplayer():
	get_parent().start_multiplayer()
	start_game()

func start_game():
	get_node("Labels").show()
	get_node("Bars").show()
	main_menu.hide()
	get_node("Title").hide()
	get_tree().set_pause(false)

