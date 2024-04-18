extends Node

const stressed_tempo_ratio = 1.16667

export (float) var trans_duration = 0.2
export (Curve) var intro_curve
export (Curve) var fade_curve

var trans_time = 0
var saved_volume = 1.0
var in_overworld = true
var stressed = false
var playing = false
var track_index = -1

var setup_ping_ignored = false

var tracks = []

func _ready():
	tracks.append(load('res://Sounds/Overworld.wav'))
	tracks.append(load('res://Sounds/Talk.wav'))
	tracks.append(load('res://Sounds/Talk_Stressed.wav'))

func _process(delta):
	if(trans_time > 0):
		trans_time -= delta
		
		var progress = 1.0
		if(playing):
			progress = intro_curve.interpolate(1 - (trans_time / trans_duration))
		else:
			progress = fade_curve.interpolate(1 - (trans_time / trans_duration))
		
		$AudioStreamPlayer.volume_db = saved_volume * progress
		
		if(trans_time <= 0):
			if(playing):
				$AudioStreamPlayer.volume_db = saved_volume
			else:
				$AudioStreamPlayer.volume_db = 0
				$AudioStreamPlayer.playing = false

func stop_playing():
	playing = false
	trans_time = trans_duration

func swap_track(index):
	if(index == track_index):
		return
	
	if(track_index == 0 || index == 0):
		# fade in when swapping between conversing and the overworld
		trans_time = trans_duration
		$AudioStreamPlayer.stream = tracks[index]
	else:
		# keep the track progress when swapping between stressed and non-stressed tracks
		var saved_progress = $AudioStreamPlayer.get_playback_position()
		var progress_multiplier = (stressed_tempo_ratio if(index == 1) else (1.0 / stressed_tempo_ratio))
		
		$AudioStreamPlayer.stream = tracks[index]
		$AudioStreamPlayer.seek(saved_progress * progress_multiplier)
	
	track_index = index
	
	if(!playing):
		playing = true
	$AudioStreamPlayer.playing = true

# get signals for convo_start, convo_end, stressed and unstressed

func on_convo_start():
	in_overworld = false
	if(stressed):
		swap_track(2)
	else:
		swap_track(1)

func on_convo_end():
	if(!setup_ping_ignored):
		setup_ping_ignored = true
		return
	
	in_overworld = true
	swap_track(0)

func on_player_stressed():
	stressed = true
	swap_track(2)

func on_player_unstressed():
	stressed = false
	if(!in_overworld):
		swap_track(1)

func on_cutscene_active():
	track_index = -1
	stop_playing()

func on_cutscene_end():
	swap_track(0)

func on_game_restart():
	trans_time = 0
	saved_volume = 1.0
	in_overworld = true
	stressed = false
	playing = false
	track_index = -1
	setup_ping_ignored = false
