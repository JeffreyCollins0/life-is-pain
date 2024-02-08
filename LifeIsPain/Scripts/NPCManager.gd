extends Node2D

var char_name = 'MissingNo.'

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
	if(mood != null):
		print('got mood value '+str(mood))
		get_parent().set_mood(mood)
	
	# set debug mugshot
	var mug = load('res://Sprites/'+char_name+'Mug_Demo.png')
	if(mug != null):
		print('Setting mugshot texture...')
		mugshot.texture = mug
	
	# set conversant name
	name_display.text = char_name+'\'s\n Mood:'
	pass

func get_npc_name():
	return char_name

func _on_ConvoManager_convo_ended():
	# get the current mood from convomanager and save to file before resetting to a dummy 0
	#var working_mood = get_parent().get_working_mood()
	#file_reader.write_mood('res://Responses/'+char_name.to_lower()+'_responses.txt', working_mood)
	#get_parent().set_mood(0)
	pass
