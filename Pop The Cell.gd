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


func _on_ReStart_pressed():
	tick = 0
	score = 0
	progress1 = 0
	progress2 = 0
	progress3 = 0
	
	timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Timer_timeout")
	get_parent().add_child(timer)
	timer.start()
	
	started = true
	reStartButton.disabled = true
	reStartButton.modulate.a = 0
	reStartButton.text = "Restart"


func _on_Timer_timeout():
	tick += 1
	get_parent().remove_child(timer)
	
	if tick % 3 == 0:
		score += 1
	
	if (randi() % 4) == 0:
		progress1 += 1
		if progress1 == 7:
			reStartButton.disabled = false
			reStartButton.modulate.a = reStartButtonModulateA
			return
	
	if (randi() % 4) == 0:
		progress2 += 1
		if progress2 == 7:
			reStartButton.disabled = false
			reStartButton.modulate.a = reStartButtonModulateA
			return
	
	if (randi() % 4) == 0:
		progress3 += 1
		if progress3 == 7:
			reStartButton.disabled = false
			reStartButton.modulate.a = reStartButtonModulateA
			return
	
	timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.connect("timeout", self, "_on_Timer_timeout")
	get_parent().add_child(timer)
	timer.start()


func _process(_delta):
	scoreLabel.text = str(score)
	if score > highscore: highscore = score
	highScoreLabel.text = str(highscore)
	progressBarButton1.rect_size.x = 10 + progress1 * 43
	progressBarButton2.rect_size.x = 10 + progress2 * 43
	progressBarButton3.rect_size.x = 10 + progress3 * 43


func _on_1_pressed():
	progress1 -= 1
	if progress1 < 0: progress1 = 0


func _on_2_pressed():
	progress2 -= 1
	if progress2 < 0: progress2 = 0


func _on_3_pressed():
	progress3 -= 1
	if progress3 < 0: progress3 = 0
