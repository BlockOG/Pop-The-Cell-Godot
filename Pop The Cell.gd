extends Control

# Labels
onready var scoreLabel = get_node("CenterContainer/VBoxContainer/Score")
onready var highScoreLabel = get_node("CenterContainer/VBoxContainer/Highscore")

# Progress buttons
onready var progressBarButton1 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar/Button")
onready var progressBarButton2 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar2/Button")
onready var progressBarButton3 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar3/Button")

# (Re)Start button
onready var reStartButton = get_node("CenterContainer/VBoxContainer/(Re)Start")

# Create the scores
var score = 0
var highscore = score
# Create the variables for "time" management
var started = false
var timer = null
var tick = 0

# Create the progresses
var progress1 = 0
var progress2 = 0
var progress3 = 0


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
	progress1 = 0
	progress2 = 0
	progress3 = 0
	
	# Start the ticks
	create_timer()
	
	# Set the started var to true and make the (Re)Start button invisible
	# and set it's text to Restart
	started = true
	reStartButton.disabled = true
	reStartButton.modulate.a = 0
	reStartButton.text = "Restart"


func do_random_add(progress):
	# There's a 1/4 chance that 1 is going to be added to the progress of a button
	if (randi() % 4) == 0:
		progress += 1
		if progress >= 7: return [7, true]
	
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
	
	# Set button widths
	progressBarButton1.rect_size.x = 10 + progress1 * 43
	progressBarButton2.rect_size.x = 10 + progress2 * 43
	progressBarButton3.rect_size.x = 10 + progress3 * 43


func do_button(progress):
	if started:
		progress -= 1
		if progress < 0: progress = 0
	return progress


# Subtract 1 from the buttons if the game is started
func _on_1_pressed(): progress1 = do_button(progress1)
func _on_2_pressed(): progress2 = do_button(progress2)
func _on_3_pressed(): progress3 = do_button(progress3)
