extends Node2D

export (int) var items_to_display = 6 #7
var current_item = 0
var selected_card = 0
var chip_base_pos = Vector2.ZERO
var chip_offset = Vector2.ZERO

var working_deck = []
var control

func _ready():
	control = get_node('../../../DeckManager')
	
	var entries = $CardChipTray.get_children()
	for i in range(len(entries)):
		entries[i].init(i, self)
	
	chip_base_pos = entries[0].position
	chip_offset = entries[1].position - chip_base_pos

func update_entries():
	var entries = $CardChipTray.get_children()
	for i in range(len(entries)):
		if(i < items_to_display):
			if(!entries[i].visible):
				entries[i].visible = true
			var card_data = control.get_card_data(working_deck[current_item + i])
			entries[i].set_display(card_data[1], (card_data[3] != -1))
		else:
			entries[i].visible = false
	
	update_buttons()

func update_selected():
	var entries = $CardChipTray.get_children()
	for i in range(len(entries)):
		entries[i].set_is_selected((current_item + i) == selected_card)

func update_buttons():
	if(current_item > 0):
		$ScrollUpButton.visible = true
	else:
		$ScrollUpButton.visible = false
		
	if(current_item + items_to_display < len(working_deck)):
		$ScrollDownButton.visible = true
	else:
		$ScrollDownButton.visible = false

func _on_ScrollUpButton_pressed():
	if(current_item > 0):
		current_item -= 1
		update_buttons()
		update_entries()

func _on_ScrollDownButton_pressed():
	var scroll_length = max(len(working_deck)-items_to_display, 0)
	if(current_item < scroll_length):
		current_item += 1
		update_buttons()
		update_entries()

func init_deck(deck):
	working_deck = deck.duplicate(false)
	update_entries()

func add_card(card):
	working_deck.append(card)
	update_entries()

func select_card(chip_id):
	var card_index = current_item + chip_id
	if(card_index == selected_card):
		selected_card = -1
	else:
		selected_card = card_index
	
	control.select_card_to_swap(self, card_index, working_deck[card_index])
	update_selected()

func get_card_position(card_index):
	var chip_index = card_index - current_item
	if(chip_index < 0 || chip_index >= items_to_display):
		return Vector2.ZERO
	
	var final_offset = (chip_base_pos + (chip_offset * chip_index))
	return final_offset

func replace_card(index, value, source_list, source_index):
	working_deck[index] = value
	
	# get original position and set target position
	var original_position = source_list.get_card_position(source_index)
	var new_position = get_card_position(index)
	
	var chips = $CardChipTray.get_children()
	var chip_index = index - current_item
	if(chip_index < 0 || chip_index >= items_to_display):
		return
	chips[chip_index].position = original_position
	chips[chip_index].target_pos = new_position
	
	update_entries()

func clear_selection():
	selected_card = -1
	update_selected()

func on_chip_hover(chip_id):
	var card_index = current_item + chip_id
	get_node('../DemoCard').set_card_id(working_deck[card_index])
