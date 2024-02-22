extends Node2D

#var topics = [ # filled dynamically
	#'HATS', 'BOXES', 'WEATHER', 'SUNGLASSES'#, 
	#'DUMMY1', 'DUMMY2', 'DUMMY3', 'DUMMY4', 'DUMMY5', 'DUMMY6', 'DUMMY7', # for testing only
	#'GIFTS', 'PLUSHIES'
#]
var topic_uses = [
	3, 3, 3, 3,
	#3, 3, 3, 3, 3, 3, 3,
	3, 3
]
var topics = [] # filled dynamically
var topic_map = {}

export (int) var items_to_display = 6 #7
export (int) var topic_cooldown = 2
export (int) var max_topic_novelty = 3
var current_item = 0
var selected_topic = 0

func _ready():
	
	var control_topics = get_parent().topics
	var control_usable = get_parent().is_topic_usable
	for i in range(len(control_topics)):
		if(control_usable[i]):
			add_topic(control_topics[i], i)
	
	var entries = $TopicChipTray.get_children()
	for i in range(len(entries)):
		entries[i].init(i)
	
	update_buttons()
	update_entries()

func update_entries():
	var entries = $TopicChipTray.get_children()
	# redo this thing here
	for i in range(len(entries)):
		if(i < min(items_to_display, len(topics))):
			if(!entries[i].visible):
				entries[i].visible = true
			entries[i].set_display(topics[current_item + i], topic_uses[current_item + i])
		else:
			entries[i].visible = false

func update_selected():
	var entries = $TopicChipTray.get_children()
	# redo this thing here
	for i in range(len(entries)):
		entries[i].set_is_selected((current_item + i) == selected_topic)

func update_buttons():
	if(current_item > 0):
		$ScrollUpButton.visible = true
	else:
		$ScrollUpButton.visible = false
		
	if(current_item + items_to_display < len(topics)):
		$ScrollDownButton.visible = true
	else:
		$ScrollDownButton.visible = false

func _on_ScrollUpButton_pressed():
	if(current_item > 0):
		current_item -= 1
		update_buttons()
		update_entries()
		update_selected()

func _on_ScrollDownButton_pressed():
	var scroll_length = max(len(topics)-items_to_display, 0)
	if(current_item < scroll_length):
		current_item += 1
		update_buttons()
		update_entries()
		update_selected()

func add_topic(topic, original_index):
	if(!topics.has(topic)):
		topics.append(topic)
		topic_uses.append(3)
		topic_map[topic] = original_index
	
		update_entries()

func select_topic(chip_id):
	#if(get_parent().is_topic_usable[current_item + chip_id]):
	var selected = topics[current_item + chip_id]
	get_parent().select_topic(topic_map[selected])
	selected_topic = current_item + chip_id
	update_selected()

func use_topic(topic):
	var index = topics.find(topic)
	if(index == -1):
		return
	topic_uses[index] -= 1
	if(topic_uses[index] <= 0):
		topic_uses[index] = -topic_cooldown
	
	# cool down the others
	for i in range(len(topic_uses)):
		if(i != index && topic_uses[i] < max_topic_novelty):
			topic_uses[i] += 1
	update_entries()

func is_topic_overused(topic):
	var index = topics.find(topic)
	if(index == -1):
		return false
	return (topic_uses[index] <= 0)

func reset_overused():
	for i in range(len(topic_uses)):
		topic_uses[i] = 3

func get_selected_topic():
	return topic_map[ topics[ selected_topic ] ]
