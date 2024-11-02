extends RigidBody2D


const SPEED: float = 700
const STEP: float = 1.05


func _ready() -> void:
	global_position.x = 960
	global_position.y = 675
	linear_velocity = Vector2(randf_range(-SPEED * 0.6, SPEED * 0.6), SPEED)
	$DeathDelay.stop()
	$SpawnDelay.start()


func increase_speed() -> void:
	var increased_velocity: Vector2 = get_linear_velocity() * Vector2(STEP, STEP)
	set_deferred("linear_velocity", increased_velocity)


func die() -> void:
	freeze = true
	$DeathDelay.start()


func _on_spawn_delay_timeout() -> void:
	freeze = false


func _on_death_delay_timeout() -> void:
	_ready()
