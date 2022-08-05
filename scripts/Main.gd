extends Node

onready var BULLET_SCENE = preload("res://scenes/Bullet.tscn")
onready var ENEMY_SCENE = preload("res://scenes/Enemy.tscn")
export var vertical_spawn_margin: int = 32
export var horizontal_spawn_margin: int = 32
var enemies: Array = []
var gates: Array = []
var spawns: Array
var player_spawns: Array
var next_spawn_location: Vector2


func _ready() -> void:
	var time = OS.get_time()
	seed(time["hour"] * 10000 + time["minute"] * 100 + time["second"])
	var _error = $YSort/Player.connect("attacked", self, "_on_Main_attacked")
	_error = $MainMenu.connect("started_game", self, "_on_Main_started_game")
	
	gates.append($YSort/UpperWalls.get_cell(0, 4))
	
	$AnimationPlayer.set_assigned_animation("FadeOut")
	$AnimationPlayer.stop()
	$OverlayLayer/ColorRect.visible = false


func _on_Main_attacked() -> void:
	# Create the bullet.
	if Globals.current_ammo_count > 0:
		Globals.current_ammo_count -= 1
		$HUD.set_ammo_count()
		var bullet = BULLET_SCENE.instance()
		var _error = bullet.connect("hit_enemy", self, "_on_Main_hit_enemy")
		var direction: Vector2 = (
				get_viewport().get_mouse_position() - Globals.player_position
		).normalized()
	
		add_child(bullet)  # Add it to the main scene.
		bullet.initialize(direction)  # Set the position and velocity.
	
		$ShootAudioStreamPlayer.play()


func _on_Main_hit_enemy(enemy) -> void:
	Globals.score += 1
	$HUD.score_label.text = "Score: {score}".format({"score": Globals.score})
	enemies.erase(enemy)
		
	if len(enemies) == 0:
		match(randi() % 4):
			0:
				$YSort/UpperWalls.set_cell(4, 0, 3)  # North gate.
				next_spawn_location = Vector2(
						Globals.screen_width / 2,
						Globals.screen_height - vertical_spawn_margin
				)  # Spawn south.
			1:
				$YSort/LowerWalls.set_cell(4, -1, 3)  # South gate.
				next_spawn_location = Vector2(
						Globals.screen_width / 2,
						vertical_spawn_margin
				)  # Spawn north.
			2:
				$YSort/UpperWalls.set_cell(9, 2, 29)  # East gate.
				next_spawn_location = Vector2(
						horizontal_spawn_margin,
						Globals.screen_height / 2
				)  # Spawn west.
			3:
				$YSort/UpperWalls.set_cell(0, 2, 30)  # West gate.
				next_spawn_location = Vector2(
						Globals.screen_width - horizontal_spawn_margin,
						Globals.screen_height / 2
				)  # Spawn east.
	
	# Update the current dice value after kill.
	var value = enemy.face_value
	$HUD.set_dice_face(value)
	$HUD.set_ammo_count()
	
	enemy.queue_free()
	$HitAudioStreamPlayer.play()


func spawn_enemy() -> void:
	var enemy = ENEMY_SCENE.instance()
	var error = enemy.connect("collided", self, "_on_Main_collided")
	var index = randi() % len(spawns)
	
	enemy.position = spawns[index].position  # Choose a random spawn.
	spawns.remove(index)
	enemies.append(enemy)
	
	add_child(enemy)


func _on_ExitArea_body_entered(body: Node) -> void:
	$OverlayLayer/ColorRect.visible = true
	$AnimationPlayer.play("FadeOut")
	$YSort/Player.set_physics_process(false)


func _on_Main_started_game() -> void:
	Globals.score = 0
	$HUD.score_label.text = "Score: {score}".format({"score": Globals.score})
	
	var roll = randi() % 6 + 1
	Globals.total_ammo_count = floor((roll + 1) / 2)
	Globals.current_ammo_count = Globals.total_ammo_count
	$HUD.set_dice_face(roll)
	$HUD.set_ammo_count()
	
	spawns = get_tree().get_nodes_in_group("EnemySpawns")
	for count in range(roll):
		spawn_enemy()
		
	Globals.game_in_progress = true
	$YSort/Player.position = Vector2(Globals.screen_width / 2, Globals.screen_height / 2)
	$MainMenu.visible = false


func _on_Main_collided(enemy, collision) -> void:
	if not $YSort/Player.get_instance_id() == collision.collider_id:
		return

	Globals.game_in_progress = false
	
	for enemy in enemies:
		enemy.queue_free()
		
	enemies = []
	$LoseAudioStreamPlayer.play()
	$MainMenu/ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/Score.text = "Score: {score}".format({"score": Globals.score})
	$MainMenu.visible = true


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "FadeOut":
		$YSort/Player.position = next_spawn_location
		$YSort/UpperWalls.set_cell(4, 0, 2)  # North gate.
		$YSort/LowerWalls.set_cell(4, -1, 10)  # East gate.
		$YSort/UpperWalls.set_cell(9, 2, 0)  # South gate.
		$YSort/UpperWalls.set_cell(0, 2, 1)  # West gate.
		$AnimationPlayer.play("FadeIn")
		
		Globals.total_ammo_count = floor((Globals.current_face_value + 1) / 2) # Last enemy killed will set this value.
		Globals.current_ammo_count = Globals.total_ammo_count
		
		spawns = get_tree().get_nodes_in_group("EnemySpawns")
		for count in range(Globals.current_face_value):
			spawn_enemy()
		for enemy in enemies:
			enemy.set_physics_process(false)
	else:
		for enemy in enemies:
			enemy.set_physics_process(true)
		$YSort/Player.set_physics_process(true)
		$OverlayLayer/ColorRect.visible = false
