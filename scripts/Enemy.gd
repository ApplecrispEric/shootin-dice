extends KinematicBody2D


signal collided(enemy, collision)
export var movement_speed: float = 30.0
var velocity: Vector2 = Vector2.ZERO
var face_value: int = randi() % 6 + 1
var face_value_speed_modifier: float = 0.2
var current_animation: String
var direction: String  # Overall direction emeny is travelling in (largest component of velocity).


func _ready() -> void:
	velocity = (Globals.player_position - self.position).normalized() * movement_speed
	$AnimationPlayer.play(str(face_value) + "WalkUp")
	
	if abs(velocity.x) >= abs(velocity.y):
		direction = "right" if velocity.x > 0 else "left"
	else:
		direction = "down" if velocity.y > 0 else "up"


func _physics_process(delta: float) -> void:
	var speed_modifier = 1 + (7 - Globals.current_face_value) * face_value_speed_modifier
	velocity = (Globals.player_position - self.position).normalized() * movement_speed * speed_modifier
	
	if (direction == "right" or direction == "left") and abs(velocity.y) > abs(velocity.x):
		direction = "up" if velocity.y < 0 else "down"
		face_value = randi() % 6 + 1
		$AnimationPlayer.play(str(face_value) + "WalkUp")
	elif (direction == "up" or direction == "down") and abs(velocity.x) > abs(velocity.y):
		direction = "right" if velocity.x > 0 else "left"
		face_value = randi() % 6 + 1
		$AnimationPlayer.play(str(face_value) + "WalkUp")
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		emit_signal("collided", self, collision)
