extends Node2D

# base set of keywords and strategies to start
var keywords = [
	'HATS', 'BOXES', 'WEATHER', 'SUNGLASSES', 'GIFTS', 'PLUSHIES'
]
var is_topic_usable = [
	true, true, true, true, false, false
]
var strategies = [] # filled dynamically by deck manager
var responses = [
	[0.4, 'They hated it.'],
	[0.4, 'They didn\'t like it...'],
	[0.4, 'They didn\'t react one way or another...'],
	[0.4, 'They liked it.'],
	[0.4, 'They loved it!']
]
var effect_bands = [
	[0.6, 'BAD'],
	[0.8, 'MID'],
	[0.6, 'GUD']
]
var base_eval = [
	[-1,   0,   -1,    0.5,  0,    0.5],
	[ 1,   0,    1,    0,   -1,   -1],
	[ 0,   0.5,  0,    1,    0,    0],
	[ 0,  -1,   -1,    1,    0,    1],
	[ 0.5,  1,   0,    0.5,  0,    0],
	[-1,   0.5,  1,    0,    0,   -1],
	[ 0,   1,    0,    0,    1,    0],
	[ 0,   0,    0.5, -1,   -1,    0.5],
	[ 0,   0.5,  0,    0,    1,    0],
	[ 1,   0,    0,   -1,    0,    1],
	[ 0,  -1,    0.5,  0,    0.5,  0]
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
var increment_prefab
var response_player

signal convo_ended
signal convo_started

func _ready():
	file_read = get_node('../FileReader');
	textbox_debug = $Control/Textbox/MarginContainer/Label
	stresscounter_debug = $StressCounter/Value
	moodcounter_debug = $MoodCounter/Value
	messagewindow_debug = $MessageRollout
	increment_prefab = load('res://Prefabs/IncrementText.tscn')
	pos_resp_track = load('res://Sounds/PositiveResponse.wav')
	neg_resp_track = load('res://Sounds/NegResp1.wav')
	
	response_player = $ResponseAudioPlayer
	
	end_convo() # for setup / testing card custom thingy

func select_topic(index):
	if(!is_topic_usable[index]):
		print('This topic is not usable.')
		return
	saved_topic = index
	$Hand.update_cards(saved_topic)

func select_strat(index):
	$TopicList_Custom.use_topic(keywords[saved_topic])
	determine_response(saved_topic, index)

func determine_response(topic_index, strat_index):
	if(cached_char_eval == null):
		cached_char_eval = file_read.read_eval(char_fpath)
	var char_eval = cached_char_eval
	
	# check if topic is overused and add the modifier if so
	if($TopicList_Custom.is_topic_overused(keywords[saved_topic])):
		$ModifierTally.add_modifier(-1.2)
	var aux_mod = $ModifierTally.get_net_modifier()
	
	# initial message
	messagewindow_debug.add_message("You told them a "+strategies[strat_index]+" about "+keywords[topic_index]+"...")
	
	# actual evaluation
	var rating_band = 'MID'
	var score = 0
	var mod = 0
	# base modifier
	var base_mod = base_eval[strat_index][topic_index]
	# npc modifiers
	var npc_mod = char_eval[0][strat_index]
	npc_mod += char_eval[1][topic_index]
	score += ((base_mod * (1 - npc_eval_percent)) + (npc_mod * npc_eval_percent))
	# add auxiliary modifiers here
	score += mod
	score += aux_mod
	
	var final_score = (score / ((3.0 * npc_eval_percent) + abs(mod)))
	print("Got final score "+str(final_score))
	rating_band = get_effect_band(final_score)
	
	# tick down the modifiers post-evaluation
	$ModifierTally.modifier_tick()
	
	# notify any active modifier cards
	$ModCardManager.update_modifiers(saved_topic, (final_score > effect_bands[0][0]))
	
	# get initial response (override if a callout applies)
	var char_response = file_read.get_response(char_fpath, keywords[topic_index], rating_band)
	if(char_response == 'MissingNo.'):
		print("defaulting back to standard responses...")
		char_response = file_read.get_response(default_fpath, keywords[topic_index], rating_band)
	
	# callout the biggest influence on the final score (for player feedback)
	var mods = [
		base_mod * (1 - npc_eval_percent),
		char_eval[0][strat_index] * npc_eval_percent,
		char_eval[1][topic_index] * npc_eval_percent,
		mod,
		aux_mod
	]
	#var callout = callout_influence(mods, file_read, char_fpath, strategies[strat_index], keywords[topic_index])
	var callout = callout_adapted(mods, file_read, char_fpath, strategies[strat_index], keywords[topic_index], rating_band)
	if(callout != 'MissingNo.'):
		char_response = callout
	
	print("Got response "+char_response+"\n")
	messagewindow_debug.add_message(get_response_band(final_score))
	
	textbox_debug.new_message(char_response)
	
	# modify stress / mood (DEBUG)
	if(rating_band == 'GUD'):
#		mood_debug += 10
#		stress_debug -= 2
		add_mood(10)
		add_stress(-2)
		
		# make increment text
#		var mood_text = increment_prefab.instance()
#		mood_text.position = $BonusTextSpawn.position
#		mood_text.init(10)
#		self.add_child(mood_text)
#		var stress_text = increment_prefab.instance()
#		stress_text.position = $StressCounter.position + Vector2(2.0, 16.0)
#		stress_text.init(2)
#		self.add_child(stress_text)
		
		# play sound
		response_player.stream = pos_resp_track
		response_player.playing = true
		
	elif(rating_band == 'BAD'):
#		mood_debug -= 5
#		stress_debug += 10
		add_mood(-5)
		add_stress(10)
		
		# make increment text
#		var mood_text = increment_prefab.instance()
#		mood_text.position = $MoodCounter.position + Vector2(0, 32.0)
#		mood_text.init(-5)
#		self.add_child(mood_text)
#		var stress_text = increment_prefab.instance()
#		stress_text.position = $StressCounter.position + Vector2(0, 32.0)
#		stress_text.init(-10)
#		self.add_child(stress_text)
		
		# play sound
		response_player.stream = neg_resp_track
		response_player.playing = true
	
#	if(mood_debug >= 100):
#		messagewindow_debug.add_message("The conversant's spirits have recovered!")
#	if(stress_debug >= 100):
#		messagewindow_debug.add_message("You're too stressed and can't think...")
#		stress_debug = 0
#		end_convo() # wait a bit for this one
	
#	stress_debug = max(min(stress_debug, 100), 0)
#	mood_debug = max(min(mood_debug, 100), 0)
#	stresscounter_debug.text = (str(stress_debug)+'%')
#	moodcounter_debug.text = (str(mood_debug)+'%')
	
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
	#control.add_stress(amount)
	stress_debug += amount
	stress_debug = min(max(stress_debug, 0), 100)
	
	var stress_text = increment_prefab.instance()
	stress_text.position = $StressCounter.position + Vector2(0, 32.0)
	stress_text.init(-amount)
	self.add_child(stress_text)
	
	stresscounter_debug.text = (str(stress_debug)+'%')
	
	if(stress_debug >= 100):
		messagewindow_debug.add_message("You're too stressed and can't think...")
		end_convo() # wait a bit for this one

func add_mood(amount):
	#control.add_mood(amount)
	mood_debug += amount
	mood_debug = min(max(mood_debug, 0), 100)
	
	var mood_text = increment_prefab.instance()
	mood_text.position = $MoodCounter.position + Vector2(0, 32.0)
	mood_text.init(amount)
	self.add_child(mood_text)
	
	moodcounter_debug.text = (str(mood_debug)+'%')
	
	if(mood_debug >= 100):
		messagewindow_debug.add_message("The conversant's spirits have recovered!")

func get_response_band(raw_score):
	var aggreg_score_band = -1
	for band in responses:
		aggreg_score_band += band[0]
		if(raw_score <= aggreg_score_band):
			return band[1]
	return "MissingNo."

# call out highest-influence aspect of joke for player feedback
func callout_adapted(mods, file_read, char_fpath, strat, topic, rating_band):
	var callout = ''
	var callout_search_term = 'MissingNo.'
	var biggest_influence = 0
	
	if(rating_band == 'GUD'):
		# callout biggest bonus
		biggest_influence = mods.max()
	else:
		# diagnose biggest demerit
		biggest_influence = mods.min()
	
	if(biggest_influence == mods[0]):
		# base matrix was the biggest determinant
		print("base matrix was the biggest determinant")
		callout_search_term = "BASE"
	elif(biggest_influence == mods[1]):
		# strategy was the biggest determinant
		print("strategy was the biggest determinant")
		callout_search_term = strat
	elif(biggest_influence == mods[2]):
		# topic was the biggest determinant
		print("topic was the biggest determinant")
		callout_search_term = topic
	elif(biggest_influence == mods[3]):
		# external modifier was the biggest determinant
		print("modifier was the biggest determinant")
		callout_search_term = "MODIFIER"
	elif(biggest_influence == mods[4]):
		# topic overuse was the biggest determinant
		print("overuse was the biggest determinant")
		callout_search_term = "OVERUSE"
	
	if(rating_band == 'MID'):
		rating_band = 'BAD'
	callout = file_read.get_response(char_fpath, callout_search_term, rating_band)
	if(callout != 'MissingNo.'):
		return callout
	else:
		return 'MissingNo.'

func process_unlocks(unlocks):
	for unlock in unlocks:
		if(unlock[0] == 1 && !is_topic_usable[unlock[1]]):
			unlock_topic(unlock[1])
		elif(unlock[0] == 0 && !(get_node('../DeckManager').is_card_usable[unlock[1]])):
			$Hand.unlock_strategy(unlock[1])

func unlock_topic(topic_index):
	is_topic_usable[topic_index] = true
	print('Unlocked topic '+keywords[topic_index])
	messagewindow_debug.add_message('You can now use the topic \"'+keywords[topic_index]+'\"!')

func get_mod(strat_index, topic_index):
	if(cached_char_eval == null):
		cached_char_eval = file_read.read_eval(char_fpath)
	
	return (cached_char_eval[0][strat_index] + cached_char_eval[1][topic_index] + base_eval[strat_index][topic_index])

func start_convo():
	print('starting conversation...')
	visible = true
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(true)
	emit_signal("convo_started")

func end_convo():
	# delete all cards
	var cards = $Hand.get_child_count()
	for i in range(cards):
		$Hand.get_child(i).queue_free()
	
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(false)
	
	visible = false
	print('conversation has ended.')
	
	get_node('../DeckManager').reset_card_uses()
	emit_signal("convo_ended")


func _on_BackButton_pressed():
	end_convo()