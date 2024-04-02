extends Node2D

export (int) var selected_offset = 32
export (int) var max_horizontal_offset = 32
export (float) var mouse_move_deadzone = 0.05

var saved_mouse_pos = Vector2.ZERO
var saved_selection = -1
var failed_draw_count = 0

# can we draw this card from the deck?
#var is_card_usable = []

var eff_up_icon = null
var eff_down_icon = null
var eff_up2_icon = null
var eff_down2_icon = null
var card_swap_track = null

var control
var deck
var card_prefab
var cancelable_player
var select_player
var messagewindow_debug
var mod_manager
var topic_list

func _ready():
	control = get_parent()
	deck = get_node('../../DeckManager')
	card_prefab = load('res://Prefabs/Card.tscn')
	messagewindow_debug = get_node('../MessageRollout')
	cancelable_player = get_node('../CancelableAudioPlayer')
	select_player = get_node('../SelectAudioPlayer')
	mod_manager = get_node('../ModCardManager')
	topic_list = get_node('../TopicList_Custom')
	
	eff_up_icon = load('res://Sprites/EffUpIconA.png')
	eff_down_icon = load('res://Sprites/EffDownIconA.png')
	eff_up2_icon = load('res://Sprites/EffUpIcon2A.png')
	eff_down2_icon = load('res://Sprites/EffDownIcon2A.png')
	card_swap_track = load('res://Sounds/CardHover.wav')

func _process(delta):
	if(get_child_count() < 5 && (deck.get_available_cards() - get_child_count()) > 0 && failed_draw_count < 5):
		#print('drawing a new card to make 5...')
		deal_random_card()
		reset_card_positions()
		update_cards(topic_list.get_selected_topic())
	
	if(get_child_count() <= 0):
		print('You have run out of cards.')
		control.end_convo()
		return
	
	# mouse movement
	var mouse_pos = get_viewport().get_mouse_position()
	if((mouse_pos - saved_mouse_pos).length() >= mouse_move_deadzone):
		if(mouse_pos.y >= position.y):
			# get section the mouse is in
			var cards = get_children()
			var section_width = (get_viewport().size.x / len(cards))
			var mouse_section_id = floor(mouse_pos.x / section_width)
			
			# set selection
			if(mouse_section_id != saved_selection):
				saved_selection = mouse_section_id
				cancelable_player.playing = true
			
			# move card indicators according to offsets
			for i in range(len(cards)):
				var card = cards[i]
				var offset = Vector2.ZERO
				var base_pos = (i * section_width)
				
				# get selection offset
				if(i == mouse_section_id):
					offset.y = -selected_offset
					card.z_index = 2
				
				else:
					card.z_index = 0
					if(i > mouse_section_id):
						offset.x = 12
					else:
						offset.x = -12
				
				var new_pos = Vector2( (base_pos) + (section_width/2.0), 0 ) + offset
				card.targ_pos = Vector2(max(min(new_pos.x, get_viewport().size.x - (section_width/1.5)), (section_width/1.5)), new_pos.y)
		
		elif(saved_mouse_pos.y >= position.y && mouse_pos.y < position.y):
			reset_card_positions()
		
		saved_mouse_pos = mouse_pos
	
	# selection
	if(Input.is_action_just_pressed("select")):
		if(mouse_pos.y >= position.y && saved_selection != -1):
			var selected_card = null
			var actual_selection = saved_selection
			if(get_child_count() > 0):
				selected_card = get_child(saved_selection)
				actual_selection = selected_card.get_card_id()
			
			var card_mod_id = selected_card.get_mod_id()
			if(card_mod_id != -1):
				# play modifier card
				get_node('../ModCardManager').play_modifier(card_mod_id)
			else:
				# play strategy card
				control.select_strat(actual_selection)
			
			deck.mark_last_used(actual_selection)
			selected_card.queue_free()
			reset_card_positions()
			
			select_player.playing = true

func reset_card_positions():
	var cards = get_children()
	if(len(cards) == 0):
		return
	var section_width = (get_viewport().size.x / len(cards))
	for i in range(len(cards)):
		cards[i].targ_pos = Vector2( (i*section_width) + (section_width/2.0), 0 )
		cards[i].z_index = 0

func update_cards(topic_index):
	var cards = get_children()
	for card in cards:
		if(card.get_mod_id() == -1):
			# only apply arrows to strategy cards
			if( abs(control.get_mod(card.get_card_id(), topic_index)) > 1 ):
				# extended update with dual-arrow icons
				card.update_topic(topic_index, eff_up2_icon, eff_down2_icon)
			else:
				card.update_topic(topic_index, eff_up_icon, eff_down_icon)

func deal_random_card():
	var card_data = deck.deal_random_card()
	if(card_data == null):
		failed_draw_count += 1
		return
	else:
		failed_draw_count = 0
	
	var new_card = card_prefab.instance()
	new_card.init(card_data)
	add_child(new_card)
	
	if(card_data[3] != -1):
		# instance a modifier onto the mod card manager
		mod_manager.new_modifier(card_data[3])

func deal_last_used_card():
	var card_data = deck.deal_last_used_card()
	if(card_data == null):
		return
	
	var new_card = card_prefab.instance()
	new_card.init(card_data)
	add_child(new_card)
	
	if(card_data[3] != -1):
		# instance a modifier onto the mod card manager
		mod_manager.new_modifier(card_data[3])

func unlock_strategy(strat_index):
	deck.is_card_usable[strat_index] = true
	var unlock_toast = 'You can now use \"'+control.strategies[strat_index]+'\"!'
	messagewindow_debug.add_message(unlock_toast)
	control.get_node('MessageLog').log_message(unlock_toast, "Internal")
