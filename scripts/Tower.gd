extends StaticBody2D

class_name Tower

signal damaged
signal powered

@export var aoe_attack_area : Area2D
@export var aoe_attack_timer : Timer

@export var MAX_HEALTH : int = 100

var current_health : int = MAX_HEALTH
var power : int = 0
var can_aoe_attack : bool = true

func _process(delta: float) -> void:
	if can_aoe_attack:
		print("aoe")
		aoe_attack()

func aoe_attack() -> void:
	# Attack all enemies in area
	for body in aoe_attack_area.get_overlapping_bodies():
		if body is Enemy:
			body.death()
	
	# Reset AOE Attack
	aoe_attack_timer.start()
	can_aoe_attack = false

func _on_damage_area_body_entered(body: Node2D) -> void:
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


func _on_aoe_attack_timer_timeout() -> void:
	can_aoe_attack = true
