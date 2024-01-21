extends Control

@export var outcome_label : Label

@export var victory_music : AudioStreamPlayer
@export var defeat_music : AudioStreamPlayer

func _ready() -> void:
	if Globals.game_outcome:
		outcome_label.text = "You win!"
		victory_music.play()
	else:
		outcome_label.text = "You lost!"
		defeat_music.play()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
