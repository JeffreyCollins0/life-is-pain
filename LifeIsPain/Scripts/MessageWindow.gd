extends Node2D

export (int) var maximum_log_length = 200
var messages = []

func add_message(message):
	#if(len(messages) >= 4):
	#	messages = []
	messages.push_front(message)
	
	while(len(messages) > maximum_log_length):
		messages.pop_back()
	
	var final_readout = ''
	#for message in messages:
	for i in range( min(4, len(messages)) ):
		final_readout = messages[i]+'\n' + final_readout
	$Content.text = final_readout

func clear():
	#messages.clear()
	$Content.text = ''
