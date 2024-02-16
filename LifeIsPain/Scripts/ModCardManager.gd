extends Node

var mod_card_prefabs = []

var control
var current_mods = []

func _ready():
	control = get_parent()
	
	mod_card_prefabs.append(load('res://Prefabs/BasicCard.tscn'))
	mod_card_prefabs.append(load('res://Prefabs/ConditionalCard.tscn'))

func new_modifier(modifier_id):
	# instance the new modifier and add it to the array
	print('adding modifier '+str(modifier_id))
	var new_mod = null
	if(modifier_id in [0, 1, 2, 3]):
		new_mod = mod_card_prefabs[1].instance()
	elif(modifier_id in [4, 5, 6, 7]):
		new_mod = mod_card_prefabs[0].instance()
	
	if(new_mod != null):
		new_mod.init(self, modifier_id)
		current_mods.append([new_mod, false])

func play_modifier(modifier_id):
	# look through and set the activated flag
	print('played mod card '+str(modifier_id))
	var to_remove = -1
	
	for i in range(len(current_mods)):
		if(current_mods[i][0].get_modifier_id() == modifier_id):
			#print('found assoc. card at index '+str(i)+', triggering on_played')
			var effect_ended = current_mods[i][0].on_played()
			current_mods[i][1] = true
			
			if(effect_ended):
				to_remove = i
			break
			
			#if(!effect_ended):
			#	current_mods[i][1] = true
			#else:
			#	current_mods.pop_at(i)
			#return
	
	# pop now-ended effect
	if(to_remove != -1):
		current_mods.pop_at(to_remove)
	#if(len(to_remove) > 0):
	#	for i in to_remove:
	#		current_mods.pop_at(i)

func update_modifiers(topic, did_joke_land):
	# loop through activated and call the function
	var to_remove = []
	
	for i in range(len(current_mods)):
		if(current_mods[i][1]):
			var effect_ended = current_mods[i][0].on_turn_update(topic, did_joke_land)
			
			if(effect_ended):
				to_remove.append(i)
				#current_mods.pop_at(i)
				#i -= 1 # prevent skipping elements
	
	# pop now-ended effects
	if(len(to_remove) > 0):
		for i in to_remove:
			current_mods.pop_at(i)

func last_joke_successful():
	return control.last_joke_successful()

func add_stress(amount):
	control.add_stress(amount)
func add_mood(amount):
	control.add_mood(amount)

func draw_card():
	get_node('../Hand').deal_random_card()
func draw_last_card():
	get_node('../Hand').deal_last_used_card()
