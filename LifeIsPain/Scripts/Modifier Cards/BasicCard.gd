extends "res://Scripts/Modifier Cards/ModCard.gd"

var control

func init(parent, modifier_index):
	control = parent
	mod_index = modifier_index

func on_played():
	#print('played a basic mod card')
	if(mod_index == 4):
		# set 'em up
		control.add_mood(5)
		print('== played [Set Em Up] ==')
	elif(mod_index == 5):
		# self-roast
		control.add_mood(6)
		control.add_stress(4)
		print('== played [Self-Roast] ==')
	elif(mod_index == 6):
		# think fast
		for i in range(3):
			control.draw_card()
		print('== played [Think Fast] ==')
	elif(mod_index == 7):
		# boomerang
		control.draw_last_card()
		print('== played [Boomerang] ==')
	
	# notify the effect has ended
	return true

func get_modifier_id():
	return mod_index
