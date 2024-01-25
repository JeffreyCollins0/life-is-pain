extends Node2D

var lib_fpath = 'res://Responses/library.txt'
var deck_fpath = 'res://Responses/player_deck.txt'
var def_deck_fpath = 'res://Responses/default_deck.txt' # debug only?

var avail_cards = 11
var library = []
var deck = [[], []]
var cached_card_data = []
var max_cache_entries = 10 # limit caching to 10 most recent cards
var saved_selection = [null, -1, -1] # selected list, local item index, card id

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
	hand.is_card_usable = packed_lib[1]
	convo_manager.strategies = packed_lib[2]
	
	# read deck from file
	deck[0] = file_reader.read_deck(deck_fpath, 11, packed_lib[1])
	print("got stored deck "+str(deck[0]))
	reset_card_uses()
	
	# initialize deck lists (on start of customization?)
	$Control/DeckList.init_deck(deck[0])
	$Control/LibList.init_deck(library)
	$Control/DemoCard.set_card_id(deck[0][0])
	
	#print("-- player deck --")
	#for card_id in range(11):
	#	var card_data = file_reader.read_card_data('res://Responses/card_data.txt', deck[card_id], false)
	#	print(str(card_id)+' '+card_data[0])
	#print('-- --')
	
	end_cust()

#func _process(delta):
#	pass

func deal_random_card():
	if(avail_cards <= 0):
		print('You have run out of cards.')
		convo_manager.end_convo()
		return null
	
	var card_id = random_gen.randi_range(0, len(deck[0])-1)
	while( !(hand.is_card_usable[card_id] && deck[1][card_id] > 0) ):
		card_id = random_gen.randi_range(0, len(deck[0])-1)
	
	var card_data = file_reader.read_card_data('res://Responses/card_data.txt', deck[0][card_id], false)
	deck[1][card_id] -= 1
	if(deck[1][card_id] <= 0):
		avail_cards -= 1
	
	return [card_id, card_data] # is this, or is it not, the actual card id?

func reset_card_uses():
	# reset available card deals
	for i in range(11):
		deck[1].append(2)
	avail_cards = 11

func get_card_data(card_id):
	var raw_data = null
	for i in range(len(cached_card_data)):
		if(cached_card_data[i][0] == card_id):
			return cached_card_data[i]
	
	if(raw_data == null):
		raw_data = file_reader.read_card_data('res://Responses/card_data.txt', card_id, false)
		var comp_data = [card_id, raw_data[0], raw_data[1]]
		
		# cache data to avoid too many file reads
		if(len(cached_card_data) >= max_cache_entries):
			var disc_item = cached_card_data.pop_front()
		cached_card_data.push_back(comp_data)
		
		return comp_data

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
			#print('swapping from list '+str(saved_selection[0]))
			swap_cards(saved_selection[0], saved_selection[1], list, item_index)
			saved_selection[0].clear_selection()
			list.clear_selection()
			saved_selection = [null, -1, -1]

func swap_cards(list1, index1, list2, index2):
	if(list1 == list2):
		# swap within a list (deck only)
		if(list1 == $Control/DeckList):
			var saved_item = list1.working_deck[index2]
			#list1.working_deck[index2] = list1.working_deck[index1]
			#list1.working_deck[index1] = saved_item
			list1.replace_card(index2, list1.working_deck[index1], list1, index1)
			list1.replace_card(index1, saved_item, list1, index2)
	else:
		# swap between lists
		if(list1 == $Control/DeckList):
			#list1.working_deck[index1] = list2.working_deck[index2]
			list1.replace_card(index1, list2.working_deck[index2], list2, index2)
		else:
			#list2.working_deck[index2] = list1.working_deck[index1]
			list2.replace_card(index2, list1.working_deck[index1], list1, index1)

func _on_DebugSaveButton_pressed():
	# save the deck to a file
	file_reader.save_deck(deck_fpath, $Control/DeckList.working_deck)
	print('saved deck to file.')

func _on_DebugLoadButton_pressed():
	# read deck from file
	deck[0] = file_reader.read_deck(deck_fpath, 11, hand.is_card_usable)
	reset_card_uses()
	
	# initialize deck lists (on start of customization?)
	$Control/DeckList.init_deck(deck[0])
	$Control/LibList.init_deck(library)
	$Control/DemoCard.set_card_id(deck[0][0])

func start_cust():
	print('starting customization...')
	visible = true
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(true)

func end_cust():
	var sub_nodes = get_children()
	for node in sub_nodes:
		node.set_process(false)
	visible = false
	print('customization has ended.')
	emit_signal("cust_ended")


func _on_BackButton_pressed():
	end_cust()
