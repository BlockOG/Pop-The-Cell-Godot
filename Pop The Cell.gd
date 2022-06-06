extends Control

# The only sound :)
onready var sound = preload("res://break.wav")

# Labels
onready var scoreLabel = get_node("CenterContainer/VBoxContainer/Scores/Score")
onready var highScoreLabel = get_node("CenterContainer/VBoxContainer/Scores/Highscore")

# Progress buttons
onready var buttons = [
	get_node("CenterContainer/VBoxContainer/Vertical/Vertical/ProgressBar/Margin/Vertical"),
	get_node("CenterContainer/VBoxContainer/Vertical/Vertical2/ProgressBar/Margin/Vertical"),
	get_node("CenterContainer/VBoxContainer/Vertical/Vertical3/ProgressBar/Margin/Vertical")
]

# Textures
onready var generators = [
	get_node("CenterContainer/VBoxContainer/Vertical/Vertical/Texture"),
	get_node("CenterContainer/VBoxContainer/Vertical/Vertical2/Texture"),
	get_node("CenterContainer/VBoxContainer/Vertical/Vertical3/Texture")
]

# Other nodes
onready var reStartButton = get_node("CenterContainer/VBoxContainer/(Re)Start")
onready var tween = get_node("Tween")
onready var verticalContainer = get_node("CenterContainer/VBoxContainer")
# Get the original size of verticalContainer
onready var origVerticalContainerSize = verticalContainer.rect_size

# Create the score variables
var score = 0
var highscore = score

# Directions for generators
var dirs = [0, 0, 0]

# Tick variables
var tick = 0
var tick_rate = 5
var tick_time = 1.0 / tick_rate


func load_hi():
	# Create file var
	var file = File.new()
	
	# Check if highscore file exists, if so read it's contents and set the highscore to that
	if file.file_exists("user://highscore"):
		file.open("user://highscore", file.READ)
		highscore = file.get_64()
		highScoreLabel.text = str(highscore)
	
	# Close the file
	file.close()

func save_hi():
	# Create file var
	var file = File.new()
	
	# Open the highscore file in write mode and write the highscore to it
	file.open("user://highscore", file.WRITE)
	file.store_64(highscore)
	
	# Close the file
	file.close()


func _ready():
	# Randomize and load highscore
	randomize()
	load_hi()
	
	# Connect all the buttons
	for j in range(3):
		for i in range(7):
			buttons[j].get_child(i).connect("pressed", self, "_on_" + str(j + 1) + "_pressed", [i])
	
	# Set size of window to not be the size of the
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
	# Create a new AudioStreamPlayer, make it automatically play when added,
	# set the audio to the previously loaded sound, connect the finished signal
	# to _on_Audio_finished and finally add it to the scene tree
	var a = AudioStreamPlayer.new()
	a.autoplay = true
	a.stream = sound
	a.connect("finished", self, "_on_Audio_finished", [a])
	get_parent().add_child(a)

func _on_Audio_finished(audio):
	# Remove the audio...
	get_parent().remove_child(audio)


func _on_ReStart_pressed():
	# Reset everything
	tick = 0
	score = 0
	for j in range(3):
		for i in range(7):
			buttons[j].get_child(i).disabled = true
	
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
	
	# Interpolate the generator movement
	tween.interpolate_property(
		generators[index],
		"rect_rotation",
		generators[index].rect_rotation,
		dirs[index] * 90,
		tick_time
	)
	tween.start()
	
	# If the generator is looking up create a new button (cell) and check if we got to the top,
	# if so return true and grab the focus of the (Re)Start button
	if abs(dirs[index] % 4) == 0:
		for i in range(6, -1, -1):
			if buttons[index].get_child(i).disabled:
				buttons[index].get_child(i).disabled = false
				break
		if !buttons[index].get_child(0).disabled:
			reStartButton.grab_focus()
			return true
	
	return false


func _on_Timer_timeout(timer):
	# Ticks update every fifth of a second
	tick += 1
	get_parent().remove_child(timer)
	
	# Score updates every 3 ticks
	if tick % 4 == 0:
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
	# If the game is started remove the clicked button (cell) and create the sound (also grab the focus of the (Re)Start button)
	if reStartButton.disabled:
		buttons[index].get_child(i).disabled = true
		reStartButton.grab_focus()
		create_sound()


# Subtract 1 from the buttons if the game is started
func _on_1_pressed(i): do_button(0, i)
func _on_2_pressed(i): do_button(1, i)
func _on_3_pressed(i): do_button(2, i)
