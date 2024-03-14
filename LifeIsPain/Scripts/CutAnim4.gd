extends Node2D

var fade_duration = 1.2
var pause_time = (fade_duration * 2.5)
var fade_time = 0
var mode = 'show' # fly and fade

signal scene_ended

func cut_process(delta):
	if(pause_time > 0):
		pause_time -= delta
		
		if(pause_time <= 0):
			pause_time = 0
			
			if(mode == 'show'):
				mode = 'fade'
				fade_time = fade_duration
			elif(mode == 'fade'):
				emit_signal("scene_ended")
	
	elif(mode == 'fade'):
		if(fade_time > 0):
			fade_time -= delta
			
			modulate = Color(1, 1, 1, (fade_time / fade_duration))
			
			if(fade_time <= 0):
				fade_time = 0
				pause_time = 0.01
