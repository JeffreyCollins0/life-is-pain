extends Label

export (float) var typewriter_speed = 1.0

var default_typewriter_duration = 0.8
var typewriter_time = 0
var audio_disabled = false

var talk_player
var talk_loop_track = null

func _ready():
	talk_player = get_node('../../../../../ConvoManager/TalkAudioPlayer')
	typewriter_time = (default_typewriter_duration / typewriter_speed)
	
	talk_loop_track = load('res://Sounds/ShadyTalk.wav')

func _process(delta):
	if(typewriter_time > 0 && !audio_disabled):
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

func reset_typewriter():
	typewriter_time = (default_typewriter_duration / typewriter_speed)
	percent_visible = 0

func _on_ConvoManager_convo_ended():
	talk_player.playing = false
	audio_disabled = true

func _on_ConvoManager_convo_started():
	audio_disabled = false
