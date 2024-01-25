extends Node2D

# shared data
const move_rate = 0.2
const move_threshold = 0.05

var card_id = -1
var card_effects = []
var targ_pos = position

func _process(delta):
	if(position.distance_to(targ_pos) >= move_threshold):
		position += ((targ_pos - position) * move_rate)
	elif(position != targ_pos):
		position = targ_pos

func init(new_card_id, card_data):
	card_id = new_card_id
	card_effects = card_data[2]
	
	# set title and description based on file read
	$CardName.text = card_data[0]
	$CardDesc.text = card_data[1]

func get_card_id():
	return card_id

func update_topic(topic_id, pos_spr, neg_spr):
	var base_mod = get_node('../..').get_mod(card_id, topic_id)
	if(base_mod > 0):
		$BaseModIndicator.visible = true
		$BaseModIndicator.texture = pos_spr
	elif(base_mod < 0):
		$BaseModIndicator.visible = true
		$BaseModIndicator.texture = neg_spr
	else:
		$BaseModIndicator.visible = false
