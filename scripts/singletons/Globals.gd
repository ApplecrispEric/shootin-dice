extends Node


onready var player_position: Vector2
onready var screen_width = ProjectSettings.get_setting("display/window/size/width")
onready var screen_height = ProjectSettings.get_setting("display/window/size/height")
var game_in_progress: bool = false
var total_ammo_count: int = 6
var current_ammo_count: int = 6
var score: int = 0
var current_face_value: int = 1
