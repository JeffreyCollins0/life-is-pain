extends Node2D

const narration_fpath = 'res://Responses/narration.txt'
const normal_max_chars = 76

export (float) var text_speed = 0.8

signal narration_paused

var default_text_duration = 2.4
var default_text_pause = 2.0
var text_time = 0
var saved_text_duration = 0
var pause_time = (default_text_pause * 1.2)

var fade_direction = 1.0
var fade_time = 0

var anim_index = -1
var anim_obj = null

var narration_pointer = 2
var paused = false
var mode = 'text' # swap between text, visual and fadein /fadeout

var skip_heat = 0 # have the skip text gradually fade after appearing

func _ready():
	$NarrationText.text = ''
	$NarrationTextShadow.text = ''

func _input(event):
	if(event.is_action_pressed("converse") && !paused):
		if(skip_heat > (default_text_pause / 2.0)):
			skip_cutscene()
		else:
			$SkipText.visible = true
			skip_heat = default_text_pause

func _process(delta):
	if(!paused):
		if(skip_heat > 0):
			skip_heat -= delta
			
			$SkipText.modulate = Color(1.0, 1.0, 1.0, (skip_heat / default_text_pause))
			
			if(skip_heat <= 0):
				skip_heat = 0
				$SkipText.visible = false
				$SkipText.modulate = Color.white
		
		if(pause_time > 0):
			pause_time -= delta
			
			if(pause_time <= 0):
				pause_time = 0
				
				# advance to the next narration bit
				invoke_narration()
		
		if(text_time > 0):
			text_time -= delta
			
			var percent_visible = (1.0 - (text_time / saved_text_duration ))
			percent_visible = max(percent_visible, 0)
			#talk_player.playing = true
			
			if(text_time <= 0):
				text_time = 0
				percent_visible = 1.0
				
				pause_time = default_text_pause
			
			$NarrationText.percent_visible = percent_visible
			$NarrationTextShadow.percent_visible = percent_visible
		
		if(mode == 'anim'):
			# run an animation update
			anim_obj.cut_process(delta)
	
	elif(fade_time > 0):
		fade_time -= delta
		
		var alpha = (fade_time / (default_text_pause * 1.2))
		if(fade_direction == 1):
			alpha = 1 - alpha
		
		$FadeBG.color = Color(0, 0, 0, alpha)
		
		if(fade_time <= 0):
			fade_time = 0
			$FadeBG.color = Color.black
			
			if(mode == 'fade in'):
				paused = false
			else:
				emit_signal("narration_paused")
				$FadeBG.visible = false
				get_tree().get_root().get_node('Spatial/Player').unlock_player_movement()
			
			pause_time = default_text_pause


# listen for a signal and connect here
func invoke_narration():
	if(paused):
		# fade in and unpause
		fade_direction = 1.0
		fade_time = (default_text_pause * 1.2)
		mode = 'fade in'
		$FadeBG.visible = true
	
	var next_line = read_next_narration()
	
	if(next_line == '[BREAK]'):
		# fade out and pause
		fade_direction = -1.0
		fade_time = (default_text_pause * 1.2)
		mode = 'fade out'
		paused = true

		$NarrationText.percent_visible = 0
		$NarrationTextShadow.percent_visible = 0

	elif(next_line.substr(0,2) == '[A'):
		# trigger animation
		# base the anims off of their own objects to adjucate the movements and such
		anim_index = int(next_line.substr(2,1))
		anim_obj = get_anim_object(anim_index)
		if(anim_obj != null):
			mode = 'anim'
			anim_obj.visible = true
			
			$NarrationText.percent_visible = 0
			$NarrationTextShadow.percent_visible = 0
		else:
			invoke_narration()
	
	elif(next_line != '[EOF]'):
		# text scroll
		if(next_line == ''):
			return
		
		mode = 'text'
		
		$NarrationText.percent_visible = 0
		$NarrationTextShadow.percent_visible = 0
		$NarrationText.text = next_line
		$NarrationTextShadow.text = next_line
		
		text_time = (float(next_line.length()) / normal_max_chars) * (default_text_duration / text_speed)
		saved_text_duration = text_time

func get_anim_object(index):
	var anim_object = null
	
	if(anim_index == 1):
		anim_object = $CutAnim1
	if(anim_index == 2):
		anim_object = $CutAnim2
	if(anim_index == 3):
		anim_object = $CutAnim3
	if(anim_index == 4):
		anim_object = $CutAnim4
	if(anim_index == 5):
		anim_object = $CutAnim5
	
	return anim_object

func on_anim_end():
	#mode = 'none'
	anim_obj.visible = false
	invoke_narration()

func read_next_narration():
	var file = File.new()
	if(!file.file_exists(narration_fpath)):
		print("File "+narration_fpath+" not found.")
		return 'MissingNo.'
	file.open(narration_fpath, File.READ)
	
	var line = ''
	
	# seek to the saved position
	for _i in range(narration_pointer):
		if(!file.eof_reached()):
			line = file.get_line()
		else:
			file.close()
			return '[EOF]'
	
	narration_pointer += 1
	file.close()
	return line

func skip_cutscene():
	var file = File.new()
	if(!file.file_exists(narration_fpath)):
		print("File "+narration_fpath+" not found.")
		return 'MissingNo.'
	file.open(narration_fpath, File.READ)
	
	for _i in range(narration_pointer):
		if(!file.eof_reached()):
			file.get_line()
		else:
			file.close()
			break
	
	# move the pointer to the end of this section
	var skipped_lines = 1
	var line = ''
	while(line != '[BREAK]'):
		if(!file.eof_reached()):
			line = file.get_line()
			skipped_lines += 1
		else:
			file.close()
			break
	
	narration_pointer += skipped_lines
	
	fade_direction = -1.0
	fade_time = (default_text_pause * 1.2)
	mode = 'fade out'
	paused = true
	
	text_time = 0
	
	$SkipText.visible = false
	$NarrationText.percent_visible = 0
	$NarrationTextShadow.percent_visible = 0
	
	if(anim_obj != null):
		anim_obj.visible = false
