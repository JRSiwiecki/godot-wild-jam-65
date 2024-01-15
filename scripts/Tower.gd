extends StaticBody2D

class_name Tower

signal damaged

@export var MAX_HEALTH : int = 100

var current_health : int = MAX_HEALTH

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		damaged.emit()
		body.death()
		current_health -= 25
		
		if current_health <= 0:
			queue_free()
			get_tree().quit()

