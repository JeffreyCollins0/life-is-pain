extends MarginContainer

export (Color) var NPCColor
export (Color) var IntColor
export (Color) var TipColor

var message_type = ''

func set_message(message, type):
	$Label.text = message
	message_type = type
	
	# set background from type
	if(message_type == 'NPC'):
		$ColorRect.color = NPCColor
	elif(message_type == 'Internal'):
		$ColorRect.color = IntColor
	elif(message_type == 'Tip'):
		$ColorRect.color = TipColor

func get_type():
	return message_type
