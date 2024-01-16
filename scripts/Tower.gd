extends StaticBody2D

class_name Tower

signal damaged
signal powered

@export var aoe_attack_area : Area2D
@export var aoe_attack_timer : Timer

@export var laser_attack_area : Area2D
@export var laser_attack_timer : Timer
@export var laser_attack_raycast : RayCast2D

@export var MAX_HEALTH : int = 100

var current_health : int = MAX_HEALTH
var power : int = 0

# Attack variables
var can_aoe_attack : bool = true
var can_laser_attack : bool = true
var can_missile_attack : bool = true
var can_spiral_attack : bool = true

func _process(_delta: float) -> void:
	if can_aoe_attack and power >= 0:
		aoe_attack()
	
	if can_laser_attack and power >= 25:
		laser_attack()
	
	if can_missile_attack and power >= 50:
		missile_attack()
	
	if can_spiral_attack and power >= 75:
		spiral_attack()

func aoe_attack() -> void:
	# Attack all enemies in area
	for body in aoe_attack_area.get_overlapping_bodies():
		if body is Enemy:
			body.death()
	
	# Reset AOE attack
	aoe_attack_timer.start()
	can_aoe_attack = false

func laser_attack() -> void:
	# Find all enemies in laser range
	var enemies : Array = []
	
	for body in laser_attack_area.get_overlapping_bodies():
		if body is Enemy:
			enemies.append(body)
	
	# Find closest enemy
	var closest_enemy : Node2D = find_closest_enemy(enemies)
	
	# No enemy found
	if !closest_enemy:
		return
	
	# Attack enemy with laser
	laser_attack_raycast.target_position = closest_enemy.global_position
	var enemy_being_attacked : Object = laser_attack_raycast.get_collider()
	
	if enemy_being_attacked and enemy_being_attacked.has_method("death"):
		enemy_being_attacked.death()
	
	# Reset laser attack
	laser_attack_timer.start()
	can_laser_attack = false

func missile_attack() -> void:
	pass

func spiral_attack() -> void:
	pass

func find_closest_enemy(enemies : Array) -> Node2D:
	var closest_enemy = null
	var shortest_distance : float = 100000.0
	for enemy in enemies:
		var distance : float = global_position.distance_to(enemy.global_position)
		
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

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


func _on_laser_attack_timer_timeout() -> void:
	can_laser_attack = true
