extends Control

signal started_game


func _on_PlayButton_pressed() -> void:
	emit_signal("started_game")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
