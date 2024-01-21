extends Control

@export var canvas_layer : CanvasLayer

@export var outcome_label : Label

func _ready() -> void:
	if Globals.game_outcome:
		outcome_label.text = "You win!"
	else:
		outcome_label.text = "You lost!"


func _on_quit_button_pressed() -> void:
	get_tree().quit()
