extends "res://Scripts/Modifier Cards/ModCard.gd"

var control

func init(parent, modifier_index):
	control = parent
	mod_index = modifier_index

func on_turn_update(topic, did_joke_land):
	#print('checking effect of conditional mod card')
	var prev_successful = control.last_joke_successful()
	
	if(mod_index == 0):
		# bury the punchline
		if(did_joke_land):
			control.add_mood(10)
		else:
			control.add_stress(10)
		print('== played [Bury The Punchline] ==')
	elif(mod_index == 1):
		# beat, beat, offbeat
		if(did_joke_land && !prev_successful):
			control.add_mood(10)
		print('== played [Beat, Beat, Offbeat] ==')
	elif(mod_index == 2):
		# hang too long
		if(did_joke_land):
			control.add_stress(-10)
		else:
			control.add_stress(10)
		print('== played [Hang Too Long] ==')
	elif(mod_index == 3):
		# improvise
		if(!prev_successful):
			control.add_mood(5)
		print('== played [Improvise] ==')
	
	# notify the effect has ended
	return true

func get_modifier_id():
	return mod_index
