extends Node

var control

func _ready():
	control = get_node('../ConvoManager')

func read_response_head(filename):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		# get line
		var line = file.get_line()
		
		# check for meta header
		if(line.substr(0,1) == '[' && line.substr(0,7) != "[_BIO_]"):
			# read meta header
			var header_data = ['', '', 0]
			
			var endofsubject_index = 0
			for i in range(1, line.length()):
				if(line.substr(i,1) == '/'):
					endofsubject_index = i+1
					header_data[0] = line.substr(1, endofsubject_index-2)
					break
			header_data[1] = line.substr(endofsubject_index, 3)
			header_data[2] = int(line.substr(endofsubject_index+4, 2))
			
			return header_data

func get_response(filename, subject, rating_band):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return 'MissingNo.'
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		# get line
		var line = file.get_line()
		
		# check for meta header
		if(line.substr(0,1) == '[' && line.substr(1.1) != "_"):
			# read meta header
			var section_subject = ''
			var endofsubject_index = 0
			for i in range(1, line.length()):
				if(line.substr(i,1) == '/'):
					endofsubject_index = i+1
					section_subject = line.substr(1, endofsubject_index-2)
					break
			var section_rating = line.substr(endofsubject_index, 3)
			# use this later for randomized response-picking
			#var section_resp_count = int(line.substr(endofsubject_index+4, 2))
			
			if(section_subject == subject && section_rating == rating_band):
				var response = file.get_line()
				file.close()
				return response
	file.close()
	return 'MissingNo.'

func read_bio(filename):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		var line = file.get_line()
		
		if(line.substr(0,7) == "[_BIO_]"):
			var bio_data = ['', '', '', '']
			bio_data[0] = file.get_line()
			var pronouns = file.get_line().split('/')
			bio_data[1] = pronouns[0]
			bio_data[2] = pronouns[1]
			bio_data[3] = pronouns[2]
			
			print("Got bio with name ["+bio_data[0]+"] and pronouns "+bio_data[1]+"/"+bio_data[2]+"/"+bio_data[3])
			
			file.close()
			return bio_data

func read_eval(filename):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		var line = file.get_line()
		
		if(line.substr(0,8) == "[_EVAL_]"):
			var eval_data = [[], []]
			for i in range(2):
				var eval_data_raw = file.get_line().split(', ')
				for element in eval_data_raw:
					eval_data[i].append(float(element))
			
			file.close()
			return eval_data

func read_mood(filename):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		var line = file.get_line()
		
		if(line.substr(0,8) == "[_MOOD_]"):
			var mood_val = int(file.get_line())
			
			file.close()
			return mood_val

func read_unlock_old(filename, subject, rating_band):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		# get line
		var line = file.get_line()
		
		# check for meta header
		if(line.substr(0,1) == '[' && line.substr(0,7) != "[_BIO_]"):
			# read meta header
			var unlocks = []
			
			var endofsubject_index = 0
			var section_subject = ''
			var endofheader_index = 0
			for i in range(1, line.length()):
				if(line.substr(i,1) == '/'):
					endofsubject_index = i+1
					section_subject = line.substr(1, endofsubject_index-2)
					break
			var section_rating = line.substr(endofsubject_index, 3)
			
			if(section_subject == subject && section_rating == rating_band):
				if(line.substr(endofsubject_index+6, 1) != ']'):
					var unlocks_length = (line.length() - (endofsubject_index + 11 + 1))
					var unlocks_str = line.substr(endofsubject_index+11, unlocks_length)
					var raw_unlocks
					raw_unlocks = unlocks_str.split(' ')
					
					for raw in raw_unlocks:
						unlocks.append([
							int(raw.substr(0,1) == 'T'), # type designator (T('topic') or S('strategy'))
							int(raw.substr(1)) # unlock index
						])
				file.close()
				return unlocks
	file.close()
	return []

func read_unlock(filename, mood):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	var unlocks = []
	while(!file.eof_reached()):
		var line = file.get_line()
		
		if(line.substr(0,10) == "[_UNLOCK_]"):
			var unlock_line = 'Sample Text'
			while(unlock_line.length() > 3):
				# read unlock data
				unlock_line = file.get_line()
				if(int(unlock_line.substr(0,3)) <= mood):
					unlocks.append([
						int(unlock_line.substr(6,1) == 'T'), # type designator (T('topic') or S('strategy'))
						int(unlock_line.substr(7)) # unlock index
					])
			break
			
	file.close()
	return unlocks

func read_card_data(filename, card_id):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	while(!file.eof_reached()):
		var line = file.get_line()
		
		if(line.substr(0,7) == "[STRAT " || line.substr(0,7) == "[MODIF "):
			if(int(line.substr(7,2)) == card_id):
				var card_data = ['', '', -1]
				
				if(line.substr(9,2) == ' |'):
					# read the modifier id
					card_data[2] = int(line.substr(12,2))
					
					#card_data_raw = file.get_line().split(', ')
					#for element in card_data_raw:
					#	card_data[2].append(float(element))
				
				var card_data_raw = file.get_line().split(' | ')
				card_data[0] = card_data_raw[0]
				card_data[1] = card_data_raw[1]
				
				file.close()
				return card_data.duplicate(true)

func read_deck(filename, deck_size, cards_usable):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	var deck = []
	
	while(!file.eof_reached()):
		var line = file.get_line()
		var iLine = int(line)
		
		if(len(deck) < deck_size && (iLine < len(cards_usable) && cards_usable[iLine])):
			deck.append(iLine)
	
	file.close()
	return deck.duplicate(true)

func save_deck(filename, deck):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.WRITE)
	
	# writing stuff
	for entry in deck:
		var padded_entry = pad_to_length(entry, 2)
		file.store_line(padded_entry)
	file.close()

func write_mood(filename, mood):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ_WRITE)
	
	# locate the mood field
	var mood_position = -1
	while(!file.eof_reached()):
		var line = file.get_line()
		
		if(line.substr(0,8) == "[_MOOD_]"):
			var pre_line_pos = file.get_position()
			var mood_val = int(file.get_line())
			mood_position = pre_line_pos
			break
	
	# write the new mood value
	if(mood_position != -1):
		file.seek(mood_position)
		file.store_string(str(mood))
	file.close()

func read_library(filename):
	var file = File.new()
	if(!file.file_exists(filename)):
		print("File "+filename+" not found.")
		return null
	file.open(filename, File.READ)
	
	var lib = [[], [], []]
	
	while(!file.eof_reached()):
		var line = file.get_line()
		lib[0].append(int(line.substr(0,2))) # card index
		lib[1].append(int(line.substr(3,1)) == 1) # card unlocked?
		lib[2].append(line.substr(5)) # card readout name
	
	file.close()
	return lib.duplicate(true)

func pad_to_length(quantity, length):
	var padded_str = str(quantity)
	while(padded_str.length() < length):
		padded_str = '0'+padded_str
	return padded_str
