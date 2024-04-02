extends Node2D

# base set of keywords and strategies to start
var topics = [
	'HATS', 'BOXES', 'WEATHER', 'SUNGLASSES', 'GIFTS', 'PLUSHIES',
	'SPACE', 'PLANTS', 'COMICS', 'FRIENDS', 'TIME'
]
var is_topic_usable = [
	true, true, true, true, false, false,
	false, false, false, false, true
]
var strategies = [] # filled dynamically by deck manager
var responses = [
	[0.6, ' hated it.'],
	[0.4, ' didn\'t like it...'],
	[0.0, ' didn\'t react one way or another...'],
	[0.4, ' liked it a little.'],
	[0.6, ' loved it!']
]
var response_templates = [
	[0.6, ' hated that ', '...'],
	[0.4, ' didn\'t like that ', '...'],
	[0.0, ' didn\'t react to that ', ' one way or another...'],
	[0.4, ' liked that ', ' a little.'],
	[0.6, ' loved that ', '!']
]
var effect_bands = [
	[0.9, 'BAD'],
	[0.2, 'MID'],
	[0.9, 'GUD']
]
var base_eval = [
	[-1,   0,   -1,    0,    0,    0.5,  1,    1,    0.5,  0,    0],
	[ 0.5, 0,    1,    0,   -1,   -1,    0.5,  0,    0,    0,    1],
	[ 0,   0.5,  0,    1,    0,    0,   -1,   -1,    1,    0.5,  0],
	[ 0,  -1,   -1,    0.5,  0,    1,    0,    0,    0.5,  1,    0],
	[ 0.5, 1,    0,    0.5,  0,    0,    0,    0,    1,   -1,   -1],
	[-1,   1,    1,    0,    0,   -1,    0,    0.5,  0,    0,  0.5],
	[ 0,   0,    0,    1,    1,    0,    0.5, -1,    0,   -1,  0.5],
	[ 1,   0,    0.5, -1,   -1,    0.5,  0,    0,    0,    0,    1],
	[ 0,   0.5,  0,    0,    1,    0,   -1,    0.5, -1,    1,    0],
	[ 1,   0,    0,   -1,    0.5,  1,    0,    0,   -1,    0.5,  0],
	[ 0,  -1,    0.5,  0,    0.5,  0,    1,    1,    0,    0,   -1]
]
var npc_eval_percent = 0.6

var test_tile_txt
var saved_topic = 0
var cached_char_eval = null
var prev_joke_result = 1.0

var stress_debug = 0
var mood_debug = 40

var default_fpath = 'res://Responses/default_responses.txt'
var char_fpath = 'res://Responses/shady_responses.txt'

var pos_resp_track = null
var neg_resp_track = null

var file_read
var textbox_debug
var stresscounter_debug
var moodcounter_debug
var messagewindow_debug
var message_log
var increment_prefab
var response_player

signal convo_ended
signal convo_started
signal conversant_recovered(name)

func _ready():
	file_read = get_node('../FileReader');
	textbox_debug = $Control/Textbox/Label
	stresscounter_debug = $StressCounter/Value
	moodcounter_debug = $MoodCounter/Value
	messagewindow_debug = $MessageRollout
	message_log = $MessageLog
	increment_prefab = load('res://Prefabs/IncrementText.tscn')
	pos_resp_track = load('res://Sounds/PositiveResponse.wav')
	neg_resp_track = load('res://Sounds/NegResp1.wav')
	
	response_player = $ResponseAudioPlayer

func select_topic(index):
	if(!is_topic_usable[index]):
		print('This topic is not usable.')
		return
	saved_topic = index
	$Hand.update_cards(saved_topic)

func select_strat(index):
	$TopicList_Custom.use_topic(topics[saved_topic])
	determine_response(saved_topic, index)

func determine_response(topic_index, strat_index):
	if(cached_char_eval == null):
		cached_char_eval = file_read.read_eval(char_fpath)
	var char_eval = cached_char_eval
	
	# check if topic is overused and add the modifier if so
	if($TopicList_Custom.is_topic_overused(topics[saved_topic])):
		$ModifierTally.add_modifier(-1.2)
	var aux_mod = $ModifierTally.get_net_modifier()
	
	# initial message
	var joke_msg = "You told "+$NPCManager.get_npc_name()+" a "+strategies[strat_index]+" about "+topics[topic_index]+"..."
	messagewindow_debug.add_message(joke_msg)
	message_log.log_message(joke_msg, "Internal")
	
	# actual evaluation
	var rating_band = 'MID'
	var score = 0
	# base modifier
	var base_mod = base_eval[strat_index][topic_index]
	# npc modifiers
	var npc_mod = char_eval[0][strat_index]
	npc_mod += char_eval[1][topic_index]
	score += ((base_mod * (1 - npc_eval_percent)) + (npc_mod * npc_eval_percent))
	# add auxiliary modifiers here
	score += aux_mod
	
	var final_score = (score / ((3.0 * npc_eval_percent) + abs(aux_mod)))
	print("Got final score "+str(final_score))
	rating_band = get_effect_band(final_score)
	
	# tick down the modifiers post-evaluation
	$ModifierTally.modifier_tick()
	
	# notify any active modifier cards
	$ModCardManager.update_modifiers(saved_topic, (rating_band != 'BAD'))
	
	# get initial response (override if a callout applies)
	var char_response = file_read.get_response(char_fpath, topics[topic_index], rating_band)
	if(char_response == 'MissingNo.'):
		print("defaulting back to standard responses...")
		char_response = file_read.get_response(default_fpath, topics[topic_index], rating_band)
	
	# callout the biggest influence on the final score (for player feedback)
	var mods = [
		base_mod * (1 - npc_eval_percent),
		char_eval[0][strat_index] * npc_eval_percent,
		char_eval[1][topic_index] * npc_eval_percent,
		aux_mod
	]
	var callout = callout_adapted(mods, file_read, char_fpath, strategies[strat_index], topics[topic_index], rating_band, final_score)
	if(callout != 'MissingNo.'):
		char_response = callout
	
	#print("Got response "+char_response+"\n")
	#messagewindow_debug.add_message(get_response_band(final_score))
	
	textbox_debug.new_message(char_response)
	message_log.log_message($NPCManager.get_npc_name()+": "+char_response, "NPC")
	
	var pre_mod_mood = mood_debug
	
	# modify stress / mood
	if(rating_band == 'GUD'):
		add_mood(5)
		add_stress(-2)
		
		# play sound
		response_player.stream = pos_resp_track
		response_player.playing = true
		
		add_tidbit()
		
	elif(rating_band == 'BAD'):
		add_mood(-5)
		add_stress(8)
		
		# play sound
		response_player.stream = neg_resp_track
		response_player.playing = true
	
	# check for percentage unlocks
	if(pre_mod_mood < mood_debug):
		var unlocks = file_read.read_unlock(char_fpath, mood_debug)
		process_unlocks(unlocks)
	
	prev_joke_result = final_score

func get_effect_band(raw_score):
	var aggreg_score_band = -1
	for band in effect_bands:
		aggreg_score_band += band[0]
		if(raw_score <= aggreg_score_band):
			return band[1]
	return "MissingNo."

func last_joke_successful():
	return (prev_joke_result > effect_bands[0][0])

func add_stress(amount):
	stress_debug += amount
	stress_debug = min(max(stress_debug, 0), 100)
	
	var stress_text = increment_prefab.instance()
	stress_text.position = $StressCounter.position + Vector2(0, 64.0) # orig. 32
	stress_text.init(-amount)
	self.add_child(stress_text)
	
	stresscounter_debug.text = (str(stress_debug)+'%')
	
	if(stress_debug >= 100):
		messagewindow_debug.add_message("You're too stressed and can't think...")
		message_log.log_message("You're too stressed and can't think...", "Internal")
		end_convo() # wait a bit for this one

func add_mood(amount):
	mood_debug += amount
	mood_debug = min(max(mood_debug, 0), 100)
	
	var mood_text = increment_prefab.instance()
	mood_text.position = $MoodCounter.position + Vector2(0, 64.0)
	mood_text.init(amount)
	self.add_child(mood_text)
	
	moodcounter_debug.text = (str(mood_debug)+'%')
	
	if(amount > 0):
		var unlocks = file_read.read_unlock(char_fpath, mood_debug)
		process_unlocks(unlocks)
	
	if(mood_debug >= 100):
		messagewindow_debug.add_message($NPCManager.get_npc_name() + "'s spirits have recovered!")
		message_log.log_message($NPCManager.get_npc_name() + "'s spirits have recovered!", "Internal")
		emit_signal("conversant_recovered", $NPCManager.get_npc_name())

func set_mood(value):
	mood_debug = value
	mood_debug = min(max(mood_debug, 0), 100)
	moodcounter_debug.text = (str(mood_debug)+'%')

func get_working_mood():
	return mood_debug

func get_response_band(raw_score):
	var aggreg_score_band = -1
	for band in responses:
		aggreg_score_band += band[0]
		if(raw_score <= aggreg_score_band):
			return $NPCManager.get_pronoun(0) + band[1]
	return "MissingNo."

func get_response_band_templated(raw_score, thing_type):
	var aggreg_score_band = -1
	for band in response_templates:
		aggreg_score_band += band[0]
		if(raw_score <= aggreg_score_band):
			return $NPCManager.get_pronoun(0) + band[1] + thing_type + band[2]
	return "MissingNo."

# call out highest-influence aspect of joke for player feedback
func callout_adapted(mods, file_read, char_fpath, strat, topic, rating_band, raw_score):
	var callout = ''
	var callout_search_term = 'MissingNo.'
	var biggest_influence = 0
	
	if(rating_band == 'GUD'):
		# callout biggest bonus
		biggest_influence = mods.max()
	else:
		# diagnose biggest demerit
		biggest_influence = mods.min()
	
	var use_note = 'MissingNo.'
	if(biggest_influence == mods[0]):
		# base matrix was the biggest determinant
		callout_search_term = "BASE"
		use_note = get_response_band_templated(raw_score, 'topic-card combo')
	elif(biggest_influence == mods[1]):
		# strategy was the biggest determinant
		callout_search_term = strat
		use_note = get_response_band_templated(raw_score, 'card')
	elif(biggest_influence == mods[2]):
		# topic was the biggest determinant
		callout_search_term = topic
		use_note = get_response_band_templated(raw_score, 'topic')
	#elif(biggest_influence == mods[3]):
	#	# external modifier was the biggest determinant
	#	callout_search_term = "MODIFIER"
	#	use_note = get_response_band_templated(raw_score, 'modifier')
	elif(biggest_influence == mods[3]):
		# topic overuse was the biggest determinant
		callout_search_term = "OVERUSE"
		use_note = $NPCManager.get_npc_name()+' seems to be getting tired of that topic...'
	
	if(use_note != 'MissingNo.'):
		messagewindow_debug.add_message(use_note)
		message_log.log_message(use_note, "Tip")
	
	if(rating_band == 'MID'):
		rating_band = 'BAD'
	callout = file_read.get_response(char_fpath, callout_search_term, rating_band)
	if(callout != 'MissingNo.'):
		return callout
	else:
		return 'MissingNo.'

func add_tidbit():
	var tidbit = $NPCManager.get_tidbit()
	if(tidbit != 'MissingNo.'):
		textbox_debug.new_message(tidbit)
		message_log.log_message($NPCManager.get_npc_name()+": "+tidbit, "NPC")

func process_unlocks(unlocks):
	for unlock in unlocks:
		var unlock_successful = false
		
		if(unlock[0] == 1 && !is_topic_usable[unlock[1]]):
			unlock_topic(unlock[1])
			unlock_successful = true
		elif(unlock[0] == 0 && !(get_node('../DeckManager').is_card_usable[unlock[1]])):
			$Hand.unlock_strategy(unlock[1])
			unlock_successful = true
		
		if(unlock_successful):
			var unlock_message = file_read.read_unlock_message(char_fpath, mood_debug)
			print('Got unlock message ['+unlock_message+'] for mood '+str(mood_debug))
			if(unlock_message != 'MissingNo.'):
				textbox_debug.new_message(unlock_message, true)
				message_log.log_message($NPCManager.get_npc_name()+": "+unlock_message, "NPC")

func unlock_topic(topic_index):
	is_topic_usable[topic_index] = true
	print('Unlocked topic '+topics[topic_index])
	var unlock_toast = 'You can now use the topic \"'+topics[topic_index]+'\"!'
	messagewindow_debug.add_message(unlock_toast)
	message_log.log_message(unlock_toast, "Internal")
	$TopicList_Custom.add_topic(topics[topic_index], topic_index)

func get_mod(strat_index, topic_index):
	if(cached_char_eval == null):
		cached_char_eval = file_read.read_eval(char_fpath)
	
	return (cached_char_eval[0][strat_index] + cached_char_eval[1][topic_index] + base_eval[strat_index][topic_index])

func start_convo(conversant):
	visible = true
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(true)
	
	$NPCManager.set_npc(conversant)
	char_fpath = 'res://Responses/'+conversant.to_lower()+'_responses.txt'
	cached_char_eval = $NPCManager.get_eval()
	
	$TopicList_Custom.reset_overused()
	
	for _i in range(5):
		$Hand.deal_random_card()
	$Hand.reset_card_positions()
	
	emit_signal("convo_started")
	
	var starter_resp = file_read.get_response(char_fpath, 'STARTER', 'GUD')
	if(starter_resp == 'MissingNo.'):
		textbox_debug.text = 'Pick a topic and card to get a response!'
	else:
		textbox_debug.new_message(starter_resp)
		message_log.log_message($NPCManager.get_npc_name()+": "+starter_resp, "NPC")

func end_convo():
	# delete all cards
	var cards = $Hand.get_child_count()
	for i in range(cards):
		$Hand.get_child(i).queue_free()
	
	# clear message boxes
	textbox_debug.text = ''
	messagewindow_debug.clear()
	
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(false)
	
	visible = false
	
	get_node('../DeckManager').reset_card_uses()
	emit_signal("convo_ended")

func _on_BackButton_pressed():
	end_convo()
