extends Node


const BRICK = preload("res://brick.tscn")
const BALL = preload("res://ball.tscn")

var score: int = 0
var high_score: int = 0
var lives: int = 3

var paddle_scale: float = 1

var paused: bool = false
var game_over: bool = false


func _ready() -> void:
	load_high_score()
	
	var new_color = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0), 1)
	$Walls/Left/ColorRect.color = new_color
	$Walls/Right/ColorRect.color = new_color
	$Walls/Top/ColorRect.color = new_color
	$Paddle/ColorRect.color = new_color
	
	for y in range(0, 8):
		for x in range(0, 16):
			var brick = BRICK.instantiate()
			brick.position.x = 120 + (100 * x) + (12 * x)
			brick.position.y = 200 + (40 * y) + (12 * y)
			$Bricks.add_child(brick)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		if  (
				paused != true
				and game_over == false
		):
			pause()
		elif paused == true:
			unpause()
	
	if Input.is_action_pressed("Press"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		var tween_paddle = get_tree().create_tween()
		tween_paddle.tween_property($Paddle, "global_position", Vector2(get_viewport().get_mouse_position().x, $Paddle.global_position.y), 0.1)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func _on_ball_body_entered(body: Node) -> void:
	var category = body.get_parent().name
	if category == "Bricks":
		var new_color = body.get_node("ColorRect").color
		$Walls/Left/ColorRect.color = new_color
		$Walls/Top/ColorRect.color = new_color
		$Walls/Right/ColorRect.color = new_color
		$Paddle/ColorRect.color = new_color
		body.free()
		$Audio/Brick.play()
		if $Bricks.get_child_count() == 0:
			win()
		increase_score()
		$Ball.increase_speed()
	elif category == "Game":
		if body.name == "Paddle":
			$Audio/Paddle.play()
			$Ball.increase_speed()
	elif category == "Walls":
		if body.name == "Bottom":
			died()
		elif body.name == "Top":
			set_paddle_scale(paddle_scale * 0.75)


func increase_score() -> void:
	set_score(score + 100)
	if score > high_score:
		set_high_score(score)


func died() -> void:
	$Ball.call_deferred("die")
	set_lives(lives-1)
	if lives == 0:
		gameover()


func set_score(num: int) -> void:
	score = num
	$UI/Scores/Score.text = str(score)


func set_high_score(num: int) -> void:
	high_score = num
	$UI/Scores/HighScore.text = str(high_score)


func set_lives(num: int) -> void:
	lives = num
	$UI/Lives/Lives.text = str(lives)


func pause() -> void:
	paused = true
	$UI/PauseScreen.visible = true
	$Paddle.process_mode = PROCESS_MODE_DISABLED
	$Ball.set_deferred("process_mode", PROCESS_MODE_DISABLED)


func unpause() -> void:
	paused = false
	$UI/PauseScreen.visible = false
	$Paddle.process_mode = PROCESS_MODE_INHERIT
	$Ball.set_deferred("process_mode", PROCESS_MODE_INHERIT)


func win() -> void:
	$UI/WinScreen.visible = true
	$Paddle.process_mode = PROCESS_MODE_DISABLED
	$Ball.set_deferred("process_mode", PROCESS_MODE_DISABLED)


func gameover() -> void:
	game_over = true
	$UI/GameOverScreen.visible = true
	save_high_score()
	$Paddle.process_mode = PROCESS_MODE_DISABLED
	$Ball.set_deferred("process_mode", PROCESS_MODE_DISABLED)


func save_high_score() -> void:
	if score == high_score:
		var file = FileAccess.open("user://hiscore", FileAccess.WRITE)
		if file != null:
			file.store_string(str(high_score))


func load_high_score() -> void:
	var file = FileAccess.open("user://hiscore", FileAccess.READ)
	if file != null:
		set_high_score(int(file.get_as_text()))


func set_paddle_scale(num: float) -> void:
	paddle_scale = num
	$Paddle.scale = Vector2(paddle_scale, 1)


func _on_play_again_pressed() -> void:
	set_score(0)
	set_lives(3)
	get_tree().call_group("bricks", "free")
	set_paddle_scale(1)
	$Paddle.global_position.x = 960
	$Paddle.process_mode = PROCESS_MODE_INHERIT
	$Ball.set_deferred("process_mode", PROCESS_MODE_INHERIT)
	$Ball._ready()
	$UI/GameOverScreen.visible = false
	$UI/WinScreen.visible = false
	game_over = false
	_ready()


func _on_resume_pressed() -> void:
	unpause()


func _on_ball_get_ready() -> void:
	$UI/GetReady.visible = true


func _on_ball_go() -> void:
	$UI/GetReady.visible = false
