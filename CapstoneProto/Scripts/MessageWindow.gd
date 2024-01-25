extends Node2D

var messages = []

func add_message(message):
	if(len(messages) >= 4):
		messages = []
	messages.push_front(message)
	
	var final_readout = ''
	for message in messages:
		final_readout = message+'\n' + final_readout
	$Content.text = final_readout
