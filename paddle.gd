extends AnimatableBody2D


const PADDLE_SPEED = 1000.0


func _physics_process(delta: float) -> void:
	var motion: Vector2
	if Input.is_action_pressed("Right"):
		motion = Vector2(delta * PADDLE_SPEED, 0)
	elif Input.is_action_pressed("Left"):
		motion = Vector2(delta * -PADDLE_SPEED, 0)
	
	move_and_collide(motion)
