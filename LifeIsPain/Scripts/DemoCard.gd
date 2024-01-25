extends Node2D

var card_id = -1

var control

func _ready():
	control = get_node('../../../DeckManager')

#func _process(delta):
#	pass

func set_card_id(new_card_id):
	if(card_id != new_card_id):
		card_id = new_card_id
		
		# read the card data
		var card_data = control.get_card_data(card_id)
		card_id = card_data[0]
		$Title.text = card_data[1]
		$Description.text = card_data[2]
