extends Area2D

class_name Power

signal collected

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collected.emit()
		queue_free()
	
	if body is Tower:
		queue_free()
