extends Node2D

# shared data
const move_rate = 0.2
const move_threshold = 0.05

var card_id = -1
var card_mod_id = -1
var targ_pos = position

var mod_backer

func _ready():
	mod_backer = load('res://Sprites/ModCardBacker.png')

func _process(delta):
	if(position.distance_to(targ_pos) >= move_threshold):
		position += ((targ_pos - position) * move_rate)
	elif(position != targ_pos):
		position = targ_pos

func init(card_data):
	card_id = card_data[0]
	card_mod_id = card_data[3]
	
	# set title and description based on card data
	$CardName.text = card_data[1]
	$CardDesc.text = card_data[2]
	
	# set card backer based on card data
	if(card_mod_id != -1):
		$Sprite.texture = load('res://Sprites/ModCardBacker.png')

func get_card_id():
	return card_id

func get_mod_id():
	return card_mod_id

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
