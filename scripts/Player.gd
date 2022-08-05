extends KinematicBody2D


signal attacked
export var move_speed: float = 100
var velocity: Vector2 = Vector2.ZERO
var face_value_speed_modifier: float = 0.0


func _physics_process(_delta: float) -> void:
	Globals.player_position = self.position
	
	var input = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	look_at(get_global_mouse_position())
	var speed_modifier = 1 - (6 - Globals.current_face_value) * face_value_speed_modifier
	velocity = input * move_speed * speed_modifier
	var _throwaway = move_and_slide(velocity)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and Globals.game_in_progress:
		emit_signal("attacked")
