extends Control

# The only sound :)
onready var sound = preload("res://break.wav")

# Labels
onready var scoreLabel = get_node("CenterContainer/VBoxContainer/Scores/Score")
onready var highScoreLabel = get_node("CenterContainer/VBoxContainer/Scores/Highscore")

# Progress buttons
onready var buttons1 = get_node("CenterContainer/VBoxContainer/Vertical/Vertical/ProgressBar/Margin/Vertical")
onready var buttons2 = get_node("CenterContainer/VBoxContainer/Vertical/Vertical2/ProgressBar/Margin/Vertical")
onready var buttons3 = get_node("CenterContainer/VBoxContainer/Vertical/Vertical3/ProgressBar/Margin/Vertical")

onready var buttons = [buttons1, buttons2, buttons3]

# Textures
onready var generator1 = get_node("CenterContainer/VBoxContainer/Vertical/Vertical/Texture")
onready var generator2 = get_node("CenterContainer/VBoxContainer/Vertical/Vertical2/Texture")
onready var generator3 = get_node("CenterContainer/VBoxContainer/Vertical/Vertical3/Texture")

onready var generators = [generator1, generator2, generator3]

# Other nodes
onready var reStartButton = get_node("CenterContainer/VBoxContainer/(Re)Start")
onready var tween = get_node("Tween")
onready var verticalContainer = get_node("CenterContainer/VBoxContainer")
# Get the original size of verticalContainer
onready var origVerticalContainerSize = verticalContainer.rect_size

# Create the score variables
var score = 0
var highscore = score

var dirs = [0, 0, 0]

var tick = 0
var tick_rate = 4
var tick_time = 1.0 / tick_rate


func load_hi():
	var file = File.new()
	
	if file.file_exists("user://highscore"):
		file.open("user://highscore", file.READ)
		highscore = file.get_64()
		highScoreLabel.text = str(highscore)
	
	file.close()

func save_hi():
	var file = File.new()
	
	file.open("user://highscore", file.WRITE)
	file.store_64(highscore)
	
	file.close()


func _ready():
	randomize()
	load_hi()
	
	# Connect all the buttons
	for i in range(7):
		buttons1.get_child(i).connect("pressed", self, "_on_1_pressed", [i])
		buttons2.get_child(i).connect("pressed", self, "_on_2_pressed", [i])
		buttons3.get_child(i).connect("pressed", self, "_on_3_pressed", [i])
	
	# Set width of window to not be the smallest possible
	OS.window_size = Vector2(1024, 600)


func create_timer():
	# Set global script variable so I can remove it later
	var timer = Timer.new()
	
	# Set timer settings and connect it
	timer.wait_time = tick_time
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Timer_timeout", [timer])
	
	# Add time and start it
	get_parent().add_child(timer)
	timer.start()

func create_sound():
	var a = AudioStreamPlayer.new()
	a.autoplay = true
	a.stream = sound
	a.connect("finished", self, "_on_Audio_finished", [a])
	get_parent().add_child(a)

func _on_Audio_finished(audio):
	get_parent().remove_child(audio)


func _on_ReStart_pressed():
	# Reset everything
	tick = 0
	score = 0
	for i in range(7):
		buttons1.get_child(i).disabled = true
		buttons2.get_child(i).disabled = true
		buttons3.get_child(i).disabled = true
	
	dirs = [0, 0, 0]
	
	# Start the ticks
	create_timer()
	
	# Make the (Re)Start button invisible and set it's text to Restart
	reStartButton.disabled = true
	reStartButton.text = "Restart"


func do_random_add(index):
	# There's a 1/2 chance that the "generator" is going to turn left or right
	if randi() % 2 == 0:
		dirs[index] += 1
	else:
		dirs[index] -= 1
	tween.interpolate_property(
		generators[index],
		"rect_rotation",
		generators[index].rect_rotation,
		dirs[index] * 90,
		tick_time
	)
	tween.start()
	
	if abs(dirs[index] % 4) == 0:
		for i in range(6, -1, -1):
			if buttons[index].get_child(i).disabled:
				buttons[index].get_child(i).disabled = false
				break
		if !buttons[index].get_child(0).disabled: return true
	
	reStartButton.grab_focus()
	return false


func _on_Timer_timeout(timer):
	# Ticks update every fifth of a second
	tick += 1
	get_parent().remove_child(timer)
	
	# Score updates every 3 ticks
	if tick % 3 == 0:
		score += 1
		if score > highscore: highscore = score
	
	# Do the random addition to the button lengths, if any button has
	# a score bigger or equal to 7, stop the game and show the restart button
	if do_random_add(0) or do_random_add(1) or do_random_add(2):
		reStartButton.disabled = false
		save_hi()
		return
	
	# Create a new timer for the next tick
	create_timer()


func _process(_delta):
	# Set score and highscore labels
	scoreLabel.text = "Score: " + str(score)
	highScoreLabel.text = "Highscore: " + str(highscore)


func do_button(index, i):
	if reStartButton.disabled:
		buttons[index].get_child(i).disabled = true
		reStartButton.grab_focus()
		create_sound()


# Subtract 1 from the buttons if the game is started
func _on_1_pressed(i): do_button(0, i)
func _on_2_pressed(i): do_button(1, i)
func _on_3_pressed(i): do_button(2, i)
