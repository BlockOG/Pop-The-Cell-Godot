extends Control

# The only sound :)
onready var sound = preload("res://break.wav")

# Labels
onready var scoreLabel = get_node("CenterContainer/VBoxContainer/Scores/Score")
onready var highScoreLabel = get_node("CenterContainer/VBoxContainer/Scores/Highscore")

# Progress buttons
onready var buttons1 = get_node("CenterContainer/VBoxContainer/Vertical/ProgressBar/Margin/Vertical")
onready var buttons2 = get_node("CenterContainer/VBoxContainer/Vertical/ProgressBar2/Margin/Vertical")
onready var buttons3 = get_node("CenterContainer/VBoxContainer/Vertical/ProgressBar3/Margin/Vertical")

# Other nodes
onready var reStartButton = get_node("CenterContainer/VBoxContainer/(Re)Start")
onready var verticalContainer = get_node("CenterContainer/VBoxContainer")
# Get the original size of verticalContainer
onready var origVerticalContainerSize = verticalContainer.rect_size

# Create the scores
var score = 0
var highscore = score

# Create the tick var
var tick = 0


func _ready():
	# Connect all the buttons
	for i in range(7):
		buttons1.get_child(i).connect("pressed", self, "_on_1_pressed", [i])
		buttons2.get_child(i).connect("pressed", self, "_on_2_pressed", [i])
		buttons3.get_child(i).connect("pressed", self, "_on_3_pressed", [i])
	
	# Set width of window to not be the smallest possible
	OS.window_size[0] = 1024


func create_timer():
	# Set global script variable so I can remove it later
	var timer = Timer.new()
	
	# Set timer settings and connect it
	timer.wait_time = 0.2
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
	
	# Start the ticks
	create_timer()
	
	# Make the (Re)Start button invisible and set it's text to Restart
	reStartButton.disabled = true
	reStartButton.modulate.a = 0
	reStartButton.text = "Restart"


func do_random_add(buttons):
	# There's a 1/4 chance that one button is going to be added
	if (randi() % 4) == 0:
		for i in range(6, -1, -1):
			if buttons.get_child(i).disabled:
				buttons.get_child(i).disabled = false
				break
		if !buttons.get_child(0).disabled: return true
	
	return false


func _on_Timer_timeout(timer):
	# Ticks update every fifth of a second
	tick += 1
	get_parent().remove_child(timer)
	
	# Score updates every 3 ticks
	if tick % 3 == 0:
		score += 1
	
	# Do the random addition to the button lengths, if any button has
	# a score bigger or equal to 7, stop the game and show the restart button
	if do_random_add(buttons1) or do_random_add(buttons2) or do_random_add(buttons3):
		reStartButton.disabled = false
		reStartButton.modulate.a = 1
		return
	
	# Create a new timer for the next tick
	create_timer()


func _process(_delta):
	# Set score label
	scoreLabel.text = "Score: " + str(score)
	
	# Set highscore and label
	if score > highscore: highscore = score
	highScoreLabel.text = "Highscore: " + str(highscore)


func do_button(buttons, i):
	if reStartButton.disabled:
		buttons.get_child(i).disabled = true
		create_sound()


# Subtract 1 from the buttons if the game is started
func _on_1_pressed(i): do_button(buttons1, i)
func _on_2_pressed(i): do_button(buttons2, i)
func _on_3_pressed(i): do_button(buttons3, i)
