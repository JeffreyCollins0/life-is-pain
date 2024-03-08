extends Node2D

var lib_fpath = 'res://Responses/library.txt'
var deck_fpath = 'res://Responses/player_deck.txt'
var def_deck_fpath = 'res://Responses/default_deck.txt' # debug only?

var avail_cards = 15
var deck_size = 15
var library = []
var library_unlocked = []
var is_card_usable = []
var deck = [[], []]
var cached_card_data = []
var max_cache_entries = 10 # limit caching to 10 most recent cards
var saved_selection = [null, -1, -1] # selected list, local item index, card id
var last_card = []

var file_reader
var convo_manager
var hand
var random_gen

signal cust_ended

func _ready():
	random_gen = RandomNumberGenerator.new()
	file_reader = get_node('../FileReader')
	convo_manager = get_node('../ConvoManager')
	hand = convo_manager.get_node('Hand')
	
	# load card library
	var packed_lib = file_reader.read_library(lib_fpath)
	library = packed_lib[0]
	is_card_usable = packed_lib[1]
	convo_manager.strategies = packed_lib[2]
	
	# filter library list by unlocks
	for i in range(len(library)):
		if(is_card_usable[i]):
			library_unlocked.append(library[i])
	
	# read deck from file
	deck[0] = file_reader.read_deck(deck_fpath, deck_size, packed_lib[1])
	reset_card_uses()
	
	# initialize deck lists
	$Control/DeckList.init_deck(deck[0])
	$Control/LibList.init_deck(library_unlocked)
	$Control/DemoCard.set_card_id(deck[0][0])

func get_available_cards():
	return avail_cards

func deal_random_card():
	if(avail_cards <= 0):
		print('You have run out of cards.')
		convo_manager.end_convo()
		return null
	
	var usable_cards = get_avail_cards()
	avail_cards = min(avail_cards, len(usable_cards))
	var rerolls = 0
	var card_id = usable_cards[random_gen.randi_range(0, len(usable_cards)-1)][1]
	while( !(is_card_usable[card_id] && deck[1][card_id] > 0) && rerolls < 20):
		card_id = usable_cards[random_gen.randi_range(0, len(usable_cards)-1)][1]
		rerolls += 1
	
	if(rerolls == 20):
		#print('[!] unable to find an available card in 20 draws... [!]')
		return null
	
	var card_data = get_card_data(deck[0][card_id])
	deck[1][card_id] -= 1
	if(deck[1][card_id] <= 0):
		avail_cards -= 1
	
	return card_data

func deal_last_used_card():
	if(last_card == []):
		return null
	
	if(is_card_usable[last_card[0]]):
		var card_pos = card_position_by_id(last_card[0])
		if(card_pos == -1):
			return null
		
		#deck[1][card_pos] = 1
		return last_card

func mark_last_used(card_id):
	last_card = get_card_data(card_id)

func get_avail_cards():
	# prevent the system from guessing too many non-options
	var avail = []
	
	for i in range(len(deck[0])):
		if(deck[1][i] > 0):
			avail.append( [deck[0][i], i] ) # value, original index in larger deck
	return avail 

func reset_card_uses():
	# reset available card deals
	for i in range(deck_size):
		if(len(deck[1]) <= i):
			deck[1].append(2)
		else:
			deck[1][i] = 2
	avail_cards = deck_size

func get_card_data(card_id):
	var raw_data = null
	for i in range(len(cached_card_data)):
		if(cached_card_data[i][0] == card_id):
			return cached_card_data[i]
	
	if(raw_data == null):
		raw_data = file_reader.read_card_data('res://Responses/card_data.txt', card_id)
		var comp_data = [card_id, raw_data[0], raw_data[1], raw_data[2]]
		
		# cache data to avoid too many file reads
		if(len(cached_card_data) >= max_cache_entries):
			var disc_item = cached_card_data.pop_front()
		cached_card_data.push_back(comp_data)
		
		return comp_data

func card_position_by_id(card_id):
	for i in range(len(deck[0])):
		if(deck[0][i] == card_id):
			return i
	return -1

func select_card_to_swap(list, item_index, card_id):
	$Control/DemoCard.set_card_id(card_id)
	
	if(saved_selection[0] == null):
		saved_selection = [list, item_index, card_id]
	else:
		if(saved_selection[0] == list && saved_selection[1] == item_index):
			# selected the same item, unselect it
			saved_selection = [null, -1, -1]
		else:
			# swap the two cards
			swap_cards(saved_selection[0], saved_selection[1], list, item_index)
			saved_selection[0].clear_selection()
			list.clear_selection()
			saved_selection = [null, -1, -1]

func swap_cards(list1, index1, list2, index2):
	if(list1 == list2):
		# swap within a list (deck only)
		if(list1 == $Control/DeckList):
			var saved_item = list1.working_deck[index2]
			list1.replace_card(index2, list1.working_deck[index1], list1, index1)
			list1.replace_card(index1, saved_item, list1, index2)
	else:
		# swap between lists
		if(list1 == $Control/DeckList):
			list1.replace_card(index1, list2.working_deck[index2], list2, index2)
		else:
			list2.replace_card(index2, list1.working_deck[index1], list1, index1)

func _on_DebugSaveButton_pressed():
	# save the deck to a file
	file_reader.save_deck(deck_fpath, $Control/DeckList.working_deck)
	print('saved deck to file.')

func _on_DebugLoadButton_pressed():
	# read deck from file
	deck[0] = file_reader.read_deck(deck_fpath, 11, is_card_usable)
	reset_card_uses()
	
	# initialize deck lists
	$Control/DeckList.init_deck(deck[0])
	$Control/LibList.init_deck(library_unlocked)
	$Control/DemoCard.set_card_id(deck[0][0])

func start_cust():
	print('starting customization...')
	visible = true
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(true)
	
	# reload library to account for unlocks
	library_unlocked.clear()
	for i in range(len(library)):
		if(is_card_usable[i]):
			library_unlocked.append(library[i])
	$Control/LibList.init_deck(library_unlocked)

func end_cust():
	$Control/DeckList.clear_selection()
	$Control/LibList.clear_selection()
	
	# copy working deck into current deck
	deck[0] = $Control/DeckList.working_deck
	
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(false)
	
	visible = false
	
	emit_signal("cust_ended")


func _on_BackButton_pressed():
	end_cust()

func _on_ConvoManager_convo_started():
	reset_card_uses()
