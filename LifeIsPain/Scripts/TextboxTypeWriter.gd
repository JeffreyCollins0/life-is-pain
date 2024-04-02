extends Label

export (float) var typewriter_speed = 1.0
export (String) var valid_delimiters = ' .,-'
const max_chars = 118 #52 # determined manually at the moment

# for queuing and chunking messages into box-sized increments
var messages = []
var message_chunks = []

var default_typewriter_duration = 0.8
var default_typewriter_pause = 1.4 #2.0
var typewriter_time = 0
var pause_time = 0
var audio_disabled = false

var talk_player
var talk_loop_track = null
var talk_indicator

func _ready():
	talk_player = get_node('../../../../ConvoManager/TalkAudioPlayer')
	typewriter_time = (default_typewriter_duration / typewriter_speed)
	talk_indicator = get_node('../TalkIndicator')
	
	talk_loop_track = load('res://Sounds/ShadyTalk.wav')

func _process(delta):
	if(pause_time > 0):
		pause_time -= delta
		
		if(pause_time <= 0):
			# check for a new message to display
			if(len(message_chunks) > 0):
				# typewriter out the next chunk of dialogue
				text = message_chunks.pop_front()
				reset_typewriter()
			elif(len(messages) > 0):
				# chunk the next message and continue on
				var next_msg = messages.pop_front()
				message_chunks.append_array(chunk_dialogue(next_msg))
				
				text = message_chunks.pop_front()
				reset_typewriter()
			else:
				talk_indicator.visible = false
			
		if(len(message_chunks) <= 0 && len(messages) <= 0 && talk_indicator.visible):
			talk_indicator.visible = false
	
	if(typewriter_time > 0 && !audio_disabled):
		typewriter_time -= delta
		
		if(!talk_indicator.visible):
			talk_indicator.visible = true
		
		percent_visible = (1.0 - (typewriter_time / (default_typewriter_duration / typewriter_speed) ))
		talk_player.playing = true
		
		if(typewriter_time <= 0):
			typewriter_time = 0
			percent_visible = 1.0
			
			pause_time = default_typewriter_pause

func new_message(message, priority=false):
	if(priority):
		messages.push_front(message)
	else:
		messages.push_back(message)
	
	# prompt the post-pause check if the system is hibernating
	if(typewriter_time <= 0 && pause_time <= 0):
		pause_time = 0.01

func clear_messages():
	messages.clear()
	message_chunks.clear()
	typewriter_time = 0
	pause_time = 0

func chunk_dialogue(message):
	var chunk_pointer = 0
	var chunks = []
	
	while(chunk_pointer < len(message)):
		if((len(message) - 1) - chunk_pointer <= max_chars):
			chunks.append(message.substr(chunk_pointer))
			break
		
		var naive_next_chunk = message.substr(chunk_pointer, max_chars)
		
		var best_stop_pos = 0
		for delimiter in valid_delimiters:
			var last_occurance = naive_next_chunk.rfind(delimiter, chunk_pointer + max_chars) + 1
			if(last_occurance > best_stop_pos):
				best_stop_pos = last_occurance
		
		chunks.append(message.substr(chunk_pointer, best_stop_pos))
		chunk_pointer += best_stop_pos
	
	return chunks

func reset_typewriter():
	typewriter_time = (float(text.length()) / max_chars) * (default_typewriter_duration / typewriter_speed)
	percent_visible = 0

func _on_ConvoManager_convo_ended():
	talk_player.playing = false
	talk_indicator.visible = false
	audio_disabled = true
	clear_messages()

func _on_ConvoManager_convo_started():
	audio_disabled = false
