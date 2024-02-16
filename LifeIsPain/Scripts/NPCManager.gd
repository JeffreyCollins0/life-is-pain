extends Node2D

var char_name = 'MissingNo.'

var working_moods = {}
var working_tidbits = {}
var working_eval = []

var mugshot
var name_display
var file_reader

func _ready():
	mugshot = get_node('../Control/Sprite')
	name_display = get_node('../MoodCounter/Title')
	file_reader = get_node('../../FileReader')

#func _process(delta):
#	pass

# TODO: dynamic mugshots based on reactions to things?

func set_npc(npc_name):
	char_name = npc_name
	var char_fname = 'res://Responses/'+char_name.to_lower()+'_responses.txt'
	
	# load bio data
	var bio_data = file_reader.read_bio(char_fname)
	var mood = file_reader.read_mood(char_fname)
	if(mood != null && !working_moods.has(char_name)):
		get_parent().set_mood(mood)
	if(working_moods.has(char_name)):
		get_parent().set_mood(working_moods[char_name])
	
	# load eval data
	working_eval = file_reader.read_eval(char_fname)
	
	# load tidbits
	if(!working_tidbits.has(char_name)):
		working_tidbits[char_name] = file_reader.read_tidbits(char_fname)
	
	# set debug mugshot
	var mug = load('res://Sprites/'+char_name+'Mug_Demo.png')
	if(mug != null):
		mugshot.texture = mug
	
	# set conversant name
	if(char_name != 'Mirror'):
		name_display.text = char_name+'\'s\n Mood:'
	else:
		name_display.text = 'Your\n Mood:'

func get_npc_name():
	if(char_name != 'Mirror'):
		return char_name
	else:
		return 'yourself'

#func is_tidbit_avail():
#	pass

func get_tidbit():
	if(working_tidbits.has(char_name)):
		var tidbits = working_tidbits[char_name]
		var tidbit_index = (randi() % len(tidbits)-1)
		return tidbits[tidbit_index]
	else:
		return 'MissingNo.'

func get_eval():
	return working_eval

func _on_ConvoManager_convo_ended():
	# get the current mood from convomanager and save to file before resetting to a dummy 0
	working_moods[char_name] = get_parent().get_working_mood()
	#file_reader.write_mood('res://Responses/'+char_name.to_lower()+'_responses.txt', working_mood)
	get_parent().set_mood(0)
	pass
