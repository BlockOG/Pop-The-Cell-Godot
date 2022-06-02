extends Control

onready var scoreLabel = get_node("CenterContainer/VBoxContainer/Score")
onready var highScoreLabel = get_node("CenterContainer/VBoxContainer/Highscore")
onready var progressBarButton1 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar/Button")
onready var progressBarButton2 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar2/Button")
onready var progressBarButton3 = get_node("CenterContainer/VBoxContainer/VBoxContainer/ProgressBar3/Button")
onready var reStartButton = get_node("CenterContainer/VBoxContainer/(Re)Start")
onready var reStartButtonModulateA = reStartButton.modulate.a

var score = 0
var highscore = score
var started = false
var timer = null
var tick = 0

var progress1 = 0
var progress2 = 0
var progress3 = 0


func create_timer():
	timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Timer_timeout")
	get_parent().add_child(timer)
	timer.start()


func _on_ReStart_pressed():
	tick = 0
	score = 0
	progress1 = 0
	progress2 = 0
	progress3 = 0
	
	create_timer()
	
	started = true
	reStartButton.disabled = true
	reStartButton.modulate.a = 0
	reStartButton.text = "Restart"


func do_random_add(progress):
	if (randi() % 4) == 0:
		progress += 1
		if progress >= 7:
			reStartButton.disabled = false
			reStartButton.modulate.a = reStartButtonModulateA
			return [7, true]
	return [progress, false]


func three_random_add(p1, p2, p3):
	var a = do_random_add(p1)
	var b = do_random_add(p2)
	var c = do_random_add(p3)
	return [a[0], b[0], c[0], a[1] or b[1] or c[1]]

# TODO: add comments everywhere
func _on_Timer_timeout():
	tick += 1
	get_parent().remove_child(timer)
	
	if tick % 3 == 0:
		score += 1
	
	var a = three_random_add(progress1, progress2, progress3)
	progress1 = a[0]
	progress2 = a[1]
	progress3 = a[2]
	if a[3]:
		started = false
		return
	
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


func _on_1_pressed(): progress1 = do_button(progress1)
func _on_2_pressed(): progress2 = do_button(progress2)
func _on_3_pressed(): progress3 = do_button(progress3)
