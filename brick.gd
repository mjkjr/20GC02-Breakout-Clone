extends StaticBody2D


func _ready() -> void:
	$ColorRect.color = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0), 1)
