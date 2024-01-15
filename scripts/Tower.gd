extends StaticBody2D

class_name Tower

signal damaged
signal powered

@export var MAX_HEALTH : int = 100

var current_health : int = MAX_HEALTH
var power : int = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		current_health -= 25
		
		if current_health <= 0:
			queue_free()
			get_tree().quit()
		
		body.death()
		damaged.emit()


func _on_power_deposit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		power += body.power_carried
		body.power_carried = 0
		powered.emit()
