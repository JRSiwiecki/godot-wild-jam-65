extends StaticBody2D

class_name Tower

signal damaged
signal powered
signal drained
signal overloaded

@export var game_over_scene : PackedScene

@export var aoe_attack_area : Area2D
@export var aoe_attack_timer : Timer
@export var aoe_attack_particles : GPUParticles2D
@export var aoe_attack_sound : AudioStreamPlayer

@export var laser_attack_area : Area2D
@export var laser_attack_timer : Timer
@export var laser_attack_raycast : RayCast2D
@export var laser_attack_line : Line2D
@export var laser_attack_sound : AudioStreamPlayer

@export var missile_scene : PackedScene
@export var missile_attack_timer : Timer
@export var explosion_sound : AudioStreamPlayer

@export var power_deposit_sound : AudioStreamPlayer
@export var overload_sound : AudioStreamPlayer
@export var tower_damaged_sound : AudioStreamPlayer
@export var shield_damaged_sound : AudioStreamPlayer

@export var reduced_cooldown_timer : Timer

@export var no_power_timer : Timer

@export var max_health : int = 100
@export var max_shield : int = 50
@export var health_regen : int = 25
@export var shield_regen : int = 25
@export var damage_per_enemy : int = 25
@export var power_drain : int = 1
@export var power_threshold: int = 125
@export var power_threshold_increase : int = 50
@export var overloads_to_win : int = 3

@export var weapon_cooldown_ratio : float  = 2.0
@export var aoe_attack_base_cooldown : float = 3.0
@export var laser_attack_base_cooldown : float = 1.5
@export var missile_attack_base_cooldown : float = 2.0

@onready var player : Player = get_node("/root/Game/Player")
@onready var closest_enemy : Node2D = null

enum POWER_LEVELS { NO_POWER = 0, LOW_POWER = 25, 
					MID_POWER = 50, HIGH_POWER = 75, 
					OVERLOAD_POWER = 100}

var current_health : int = max_health
var shield : int = 0
var power : int = 25
var overload_count : int = 0

# Attack variables
var can_aoe_attack : bool = true
var can_laser_attack : bool = true
var can_missile_attack : bool = true

func _ready() -> void:
	reset_weapon_cooldowns()

func _process(_delta: float) -> void:
	closest_enemy = find_closest_enemy()
	
	if can_aoe_attack and power >= POWER_LEVELS.LOW_POWER:
		aoe_attack()
	
	if can_laser_attack and (power >= POWER_LEVELS.MID_POWER or overload_count >= 1):
		laser_attack()
	
	if can_missile_attack and (power >= POWER_LEVELS.HIGH_POWER or overload_count >= 2):
		missile_attack()

func regenerate_health() -> void:
	current_health += health_regen
	current_health = clampi(current_health, 0, max_health)

func regenerate_shield() -> void:
	shield += shield_regen
	shield = clampi(shield, 0, max_shield)

func reduce_weapon_cooldowns() -> void:
	# Don't reduce cooldowns if they are already lowered
	if !reduced_cooldown_timer.is_stopped():
		return
	
	aoe_attack_timer.wait_time = aoe_attack_base_cooldown / weapon_cooldown_ratio
	laser_attack_timer.wait_time = laser_attack_base_cooldown / weapon_cooldown_ratio
	missile_attack_timer.wait_time = missile_attack_base_cooldown / weapon_cooldown_ratio
	
	reduced_cooldown_timer.start()

func reset_weapon_cooldowns() -> void:
	aoe_attack_timer.wait_time = aoe_attack_base_cooldown
	laser_attack_timer.wait_time = laser_attack_base_cooldown
	missile_attack_timer.wait_time = missile_attack_base_cooldown

func aoe_attack() -> void:
	# Attack all enemies in area
	for body in aoe_attack_area.get_overlapping_bodies():
		if body is Enemy:
			body.death(Enemy.DEATH_METHODS.EXPLODED)
	
	aoe_attack_particles.restart()
	
	# Reset AOE attack
	aoe_attack_timer.start()
	can_aoe_attack = false
	
	aoe_attack_sound.play()

func laser_attack() -> void:
	# No enemy found
	if !closest_enemy:
		return
	
	# Attack enemy with laser
	laser_attack_raycast.target_position = closest_enemy.global_position
	
	var enemy_being_attacked : Object = laser_attack_raycast.get_collider()
	
	if enemy_being_attacked and enemy_being_attacked.has_method("death"):
		# Draw the laser beam
		laser_attack_line.points = [global_position, enemy_being_attacked.global_position]
		
		enemy_being_attacked.death(Enemy.DEATH_METHODS.LASERED)
		
		laser_attack_sound.play()
		
		# Reset laser attack
		laser_attack_timer.start()
		can_laser_attack = false

func missile_attack() -> void:
	# No enemy found
	if !closest_enemy:
		return
	
	# Fire missile
	var missile : Missile = missile_scene.instantiate()
	owner.add_child(missile)
	missile.target = closest_enemy
	
	missile.exploded.connect(_on_missile_exploded)
	
	missile_attack_timer.start()
	can_missile_attack = false

func find_closest_enemy() -> Node2D:
	# Find all enemies in laser range
	var enemies : Array = []
	
	for body in laser_attack_area.get_overlapping_bodies():
		if body is Enemy:
			enemies.append(body)
	
	var shortest_distance : float = 100000.0
	for enemy in enemies:
		var distance : float = global_position.distance_to(enemy.global_position)
		
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func overload() -> void:
	power_threshold += power_threshold_increase
	power = POWER_LEVELS.LOW_POWER
	overload_count += 1
	overloaded.emit()
	
	overload_sound.play()
	
	if overload_count >= overloads_to_win:
		tower_fully_powered.call_deferred()

func tower_death() -> void:
	player.death()
	await get_tree().create_timer(1.1).timeout
	
	queue_free()
	Globals.game_outcome = false
	
	get_tree().change_scene_to_packed(game_over_scene)

func tower_fully_powered() -> void:
	Globals.game_outcome = true
	get_tree().change_scene_to_packed(game_over_scene)

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		
		# Use shield first
		var leftover_damage : int = damage_per_enemy
		if shield >= 0:
			leftover_damage = damage_per_enemy - shield
			leftover_damage = clampi(leftover_damage, 0, leftover_damage)
			
			shield -= damage_per_enemy
			shield = max(shield, 0)
			shield_damaged_sound.play()
		
		if leftover_damage > 0:
			current_health -= leftover_damage
			tower_damaged_sound.play()
		
		if current_health <= 0:
			player.death()
			tower_death.call_deferred()
		
		player.take_damage()
		
		body.death(Enemy.DEATH_METHODS.NONE)
		damaged.emit()

func _on_power_deposit_area_body_entered(body: Node2D) -> void:
	if body is Player and body.power_carried > 0:
		power += body.power_carried
		body.power_carried = 0
		
		power_deposit_sound.play()
		
		if power >= power_threshold:
			overload()
		
		# POWER, HEALTH, SHIELD, SPEED
		for power_type in body.power_types_carried:
			match power_type:
				Power.POWER_TYPE.HEALTH:
					regenerate_health()
				Power.POWER_TYPE.SHIELD:
					regenerate_shield()
				Power.POWER_TYPE.SPEED:
					reduce_weapon_cooldowns()
		
		body.reset_power_types_carried()
		no_power_timer.stop()
		powered.emit()

func _on_aoe_attack_timer_timeout() -> void:
	can_aoe_attack = true


func _on_laser_attack_timer_timeout() -> void:
	can_laser_attack = true


func _on_missile_attack_timer_timeout() -> void:
	can_missile_attack = true


func _on_no_power_timer_timeout() -> void:
	tower_death()


func _on_drain_power_timer_timeout() -> void:
	power = max(power - power_drain, 0)
	
	if power <= 0 and no_power_timer.is_stopped():
		no_power_timer.start()
	
	drained.emit()


func _on_reduced_cooldown_timer_timeout() -> void:
	reset_weapon_cooldowns()

func _on_missile_exploded() -> void:
	explosion_sound.play()
