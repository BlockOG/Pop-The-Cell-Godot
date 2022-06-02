extends Control

# Labels
onready var scoreLabel = get_node("CenterContainer/VBoxContainer/Score")
onready var highScoreLabel = get_node("CenterContainer/VBoxContainer/Highscore")

# Progress buttons
onready var buttons1 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar/Margin/Horizontal")
onready var buttons2 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar2/Margin/Horizontal")
onready var buttons3 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar3/Margin/Horizontal")

# (Re)Start button
onready var reStartButton = get_node("CenterContainer/VBoxContainer/(Re)Start")

# Create the scores
var score = 0
var highscore = score

# Create the variables for "time" management
var timer = null
var tick = 0
var started = false

# Create progresses
var progress1 = [false,false,false,false,false,false,false]
var progress2 = [false,false,false,false,false,false,false]
var progress3 = [false,false,false,false,false,false,false]


func _ready():
	for i in range(7):
		buttons1.get_child(i).connect("pressed", self, "_on_1_pressed", [i])
		buttons2.get_child(i).connect("pressed", self, "_on_2_pressed", [i])
		buttons3.get_child(i).connect("pressed", self, "_on_3_pressed", [i])


func create_timer():
	# Set global script variable so I can remove it later
	timer = Timer.new()
	
	# Set timer settings and connect it
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Timer_timeout")
	
	# Add time and start it
	get_parent().add_child(timer)
	timer.start()


func _on_ReStart_pressed():
	# Reset everything
	tick = 0
	score = 0
	for i in range(7):
		progress1[i] = false
		progress2[i] = false
		progress3[i] = false
	
	# Start the ticks
	create_timer()
	
	# Set the started var to true and make the (Re)Start button invisible
	# and set it's text to Restart
	started = true
	reStartButton.disabled = true
	reStartButton.modulate.a = 0
	reStartButton.text = "Restart"


func do_random_add(progress):
	# There's a 1/4 chance that one button is going to be added
	if (randi() % 4) == 0:
		for i in range(7):
			if !progress[i]:
				progress[i] = true
				break
		if progress[6]: return [[true,true,true,true,true,true,true], true]
	
	return [progress, false]

func three_random_add(p1, p2, p3):
	# Do the previous func with all 3 progresses
	var a = do_random_add(p1)
	var b = do_random_add(p2)
	var c = do_random_add(p3)
	return [a[0], b[0], c[0], a[1] or b[1] or c[1]]


func _on_Timer_timeout():
	# Ticks update every fifth of a second
	tick += 1
	get_parent().remove_child(timer)
	
	# Score updates every 3 ticks
	if tick % 3 == 0:
		score += 1
	
	# Do the random addition to the button lengths
	var a = three_random_add(progress1, progress2, progress3)
	progress1 = a[0]
	progress2 = a[1]
	progress3 = a[2]
	# Check if any button has a score bigger or equal to 7
	# If so stop the game and show the restart button
	if a[3]:
		started = false
		reStartButton.disabled = false
		reStartButton.modulate.a = 1
		return
	
	# Create a new timer for the next tick
	create_timer()


func _process(_delta):
	# Set score label
	scoreLabel.text = str(score)
	
	# Set highscore and label
	if score > highscore: highscore = score
	highScoreLabel.text = str(highscore)
	
	# Sync the progresses
	for i in range(7):
		buttons1.get_child(i).disabled = !progress1[i]
		buttons2.get_child(i).disabled = !progress2[i]
		buttons3.get_child(i).disabled = !progress3[i]


func do_button(progress, i):
	if started:
		progress[i] = false
	return progress


# Subtract 1 from the buttons if the game is started
func _on_1_pressed(i): progress1 = do_button(progress1, i)
func _on_2_pressed(i): progress2 = do_button(progress2, i)
func _on_3_pressed(i): progress3 = do_button(progress3, i)
