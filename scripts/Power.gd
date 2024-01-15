extends Area2D

class_name Power

signal collected

@onready var player : Player = get_node("/root/Game/Player")

func _on_body_entered(body: Node2D) -> void:
	if body is Player and player.power_carried < player.CARRY_CAPACITY:
		collected.emit()
		queue_free()
	
	if body is Tower:
		queue_free()
