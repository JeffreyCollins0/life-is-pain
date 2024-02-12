extends Node2D

var char_name = 'MissingNo.'

var working_moods = {}

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
	
	# load bio data
	var bio_data = file_reader.read_bio('res://Responses/'+char_name.to_lower()+'_responses.txt')
	var mood = file_reader.read_mood('res://Responses/'+char_name.to_lower()+'_responses.txt')
	if(mood != null && !working_moods.has(char_name)):
		print('got mood value '+str(mood))
		get_parent().set_mood(mood)
	if(working_moods.has(char_name)):
		print('got cached mood value '+str(working_moods[char_name]))
		get_parent().set_mood(working_moods[char_name])
	
	# set debug mugshot
	var mug = load('res://Sprites/'+char_name+'Mug_Demo.png')
	if(mug != null):
		print('Setting mugshot texture...')
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

func _on_ConvoManager_convo_ended():
	# get the current mood from convomanager and save to file before resetting to a dummy 0
	#var working_mood = get_parent().get_working_mood()
	working_moods[char_name] = get_parent().get_working_mood()
	#file_reader.write_mood('res://Responses/'+char_name.to_lower()+'_responses.txt', working_mood)
	get_parent().set_mood(0)
	pass
