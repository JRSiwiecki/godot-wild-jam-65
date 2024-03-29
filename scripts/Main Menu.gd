extends Control

@export var game_scene : PackedScene

@export var main_menu_music : AudioStreamPlayer

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
