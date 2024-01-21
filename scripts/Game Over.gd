extends Control

@export var background : ColorRect
@export var outcome_label : Label
@export var victory_music : AudioStreamPlayer
@export var defeat_music : AudioStreamPlayer

func _ready() -> void:
	if Globals.game_outcome:
		background.color = Color.DARK_GREEN
		outcome_label.text = "You win!"
		victory_music.play()
	else:
		background.color = Color.INDIAN_RED
		outcome_label.text = "You lost!"
		defeat_music.play()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
