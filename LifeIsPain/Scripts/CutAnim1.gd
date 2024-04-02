extends Node2D

export (float) var frame_delay = 0.15 #0.2
var fade_duration = 1.2
var frame_time = frame_delay
var pause_time = 0
var fade_time = 0
var mode = 'frame' # fly and fade

signal scene_ended

func cut_process(delta):
	if(pause_time > 0):
		pause_time -= delta
		
		if(pause_time <= 0):
			pause_time = 0
			
			if(mode == 'frame'):
				mode = 'fade'
				fade_time = fade_duration
			elif(mode == 'fade'):
				emit_signal("scene_ended")
	
	elif(mode == 'frame'):
		if(frame_time > 0):
			frame_time -= delta
			
			if(frame_time <= 0):
				frame_time = 0
				
				#print('comparing frame id '+str($AnimatedSprite.frame)+' to count '+str($AnimatedSprite.frames.get_frame_count('default')))
				if($AnimatedSprite.frame < $AnimatedSprite.frames.get_frame_count('default')-1):
					$AnimatedSprite.frame += 1
					frame_time = frame_delay
				else:
					pause_time = fade_duration
	
	elif(mode == 'fade'):
		if(fade_time > 0):
			fade_time -= delta
			
			modulate = Color(1, 1, 1, (fade_time / fade_duration))
			
			if(fade_time <= 0):
				fade_time = 0
				pause_time = 0.01
