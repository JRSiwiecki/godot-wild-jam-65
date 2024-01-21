extends Control

@export var tower : Tower
@export var player : Player
@export var game : Game

@export var overload_filled_texture : Texture

@export var carry_slot_texture : Texture
@export var carry_filled_texture : Texture

@export var tower_power_bar : ProgressBar
@export var tower_health_bar : ProgressBar
@export var tower_shield_bar : ProgressBar

@export var overload_slot_1 : TextureRect
@export var overload_slot_2 : TextureRect
@export var overload_slot_3 : TextureRect

@export var carry_slot_1 : TextureRect
@export var carry_slot_2 : TextureRect
@export var carry_slot_3 : TextureRect

func _ready() -> void:
	update_health_label()
	update_shield_label()
	update_power_label()
	update_overloaded_label()
	update_carrying_power_label()

func update_health_label() -> void:
	tower_health_bar.value = tower.current_health

func update_shield_label() -> void:
	tower_shield_bar.value = tower.shield

func update_power_label() -> void:
	tower_power_bar.value = tower.power
	tower_power_bar.max_value = tower.power_threshold

func update_overloaded_label() -> void:
	if tower.overload_count == 1:
		overload_slot_1.texture = overload_filled_texture
	
	if tower.overload_count == 2:
		overload_slot_2.texture = overload_filled_texture
	
	if tower.overload_count == 3:
		overload_slot_3.texture = overload_filled_texture

func update_carrying_power_label() -> void:
	if player.power_carried <= 0:
		carry_slot_1.texture = carry_slot_texture
		carry_slot_2.texture = carry_slot_texture
		carry_slot_3.texture = carry_slot_texture
	
	if player.power_carried > 0:
		carry_slot_1.texture = carry_filled_texture
	
	if player.power_carried >= 25:
		carry_slot_2.texture = carry_filled_texture
	
	if player.power_carried >= 50:
		carry_slot_3.texture = carry_filled_texture

func _on_tower_damaged() -> void:
	update_health_label()
	update_shield_label()

# Power collected
func _on_game_collected() -> void:
	update_carrying_power_label()

func _on_tower_powered() -> void:
	update_power_label()
	update_health_label()
	update_shield_label()
	update_overloaded_label()

func _on_tower_drained() -> void:
	update_power_label()
