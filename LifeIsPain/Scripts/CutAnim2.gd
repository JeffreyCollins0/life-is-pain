extends Node2D

export (float) var move_spd = 48
var fade_duration = 1.2
var pause_time = 0
var fade_time = 0
var mode = 'fly' # fly and fade
var start_pos = Vector2.ZERO

signal scene_ended

func _ready():
	start_pos = position

func cut_process(delta):
	if(pause_time > 0):
		pause_time -= delta
		
		if(pause_time <= 0):
			pause_time = 0
			
			if(mode == 'fly'):
				mode = 'fade'
				fade_time = fade_duration
			elif(mode == 'fade'):
				emit_signal("scene_ended")
	
	elif(mode == 'fly'):
		var pos_diff = Vector2.ZERO - position
		
		if(pos_diff.length() >= (delta * move_spd)):
			position += pos_diff.normalized() * delta * move_spd
		else:
			position = Vector2.ZERO
			pause_time = (fade_duration / 2.0)
	
	elif(mode == 'fade'):
		if(fade_time > 0):
			fade_time -= delta
			
			modulate = Color(1, 1, 1, (fade_time / fade_duration))
			
			if(fade_time <= 0):
				fade_time = 0
				pause_time = 0.01

func _on_Narrator_game_restart():
	modulate = Color(1, 1, 1, 1)
	pause_time = 0
	fade_time = 0
	mode = 'fly' # fly and fade
	position = start_pos
