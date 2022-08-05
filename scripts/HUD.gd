extends Control

onready var reload_timer = $MarginContainer/Control/ReloadTimer
onready var dice = $MarginContainer/Control/Dice
onready var animation_player = $MarginContainer/Control/AnimationPlayer
onready var ammo_label = $MarginContainer/Control/AmmoCount
onready var score_label = $MarginContainer/Control/Score


func _ready() -> void:
	reload_timer.visible = false


func set_dice_face(face: int) -> void:
	dice.frame = int(clamp(face, 1, 6) - 1)
	Globals.current_face_value = face


func set_ammo_count() -> void:
	ammo_label.text = " {current}/{total} ".format(
			{"current": Globals.current_ammo_count, "total": Globals.total_ammo_count}
	)
	
	Globals.current_ammo_count = clamp(Globals.current_ammo_count, 0, Globals.total_ammo_count)
	
	if Globals.current_ammo_count == 0:
		reload_timer.visible = true
		animation_player.play("ReloadTimer")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	Globals.current_ammo_count = Globals.total_ammo_count
	self.set_ammo_count()
	reload_timer.visible = false
