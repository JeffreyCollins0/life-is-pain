extends Label

export (float) var typewriter_speed = 1.0

var default_typewriter_duration = 0.8
var typewriter_time = 0
var talk_player

var talk_loop_track = null

func _ready():
	talk_player = get_tree().get_current_scene().get_node('ConvoManager/TalkAudioPlayer')
	typewriter_time = (default_typewriter_duration / typewriter_speed)
	
	talk_loop_track = load('res://Sounds/ShadyTalk.wav')

func _process(delta):
	if(typewriter_time > 0):
		typewriter_time -= delta
		
		percent_visible = (1.0 - (typewriter_time / (default_typewriter_duration / typewriter_speed) ))
		talk_player.playing = true
		
		if(typewriter_time <= 0):
			typewriter_time = 0
			percent_visible = 1.0

func new_message(message):
	text = message
	percent_visible = 0
	typewriter_time = (default_typewriter_duration / typewriter_speed)
