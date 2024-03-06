extends Panel

const text_fname = 'res://Responses/tutorial_data.txt'
var tutorial_title = 'MissingNo.'
var index_range = [-1, -1]
var current_index = -1

func init(title, start_index = -1, end_index = -1):
	tutorial_title = title
	
	index_range = [start_index, end_index]
	current_index = 1
	if(start_index != -1):
		current_index = start_index
	
	var img = get_tutorial_image()
	if(img != null):
		$TextureRect.texture = img
	
	var text = get_tutorial_text()
	if(text != null):
		$Label2.text = text

func next_page():
	if(current_index >= index_range[1]):
		# end of section reached, report that we finished it
		visible = false
		return
	
	current_index += 1
	
	var img = get_tutorial_image()
	if(img != null):
		$TextureRect.texture = img
	
	var text = get_tutorial_text()
	if(text != null):
		$Label2.text = text

func get_tutorial_image():
	var tut_fname = 'res://TutorialImages/'+tutorial_title+'_'+str(current_index)+'.png'
	
	var file = File.new()
	if(!file.file_exists(tut_fname)):
		print("File "+tut_fname+" not found.")
		return null
	
	return load(tut_fname)

func get_tutorial_text():
	var file = File.new()
	if(!file.file_exists(text_fname)):
		print("File "+text_fname+" not found.")
		return null
	file.open(text_fname, File.READ)
	
	while(!file.eof_reached()):
		var line = file.get_line()
		
		var content = ''
		var post_title_pos = (2 + len(tutorial_title))
		if(line.substr(0,1) == '[' && line.substr(1, len(tutorial_title)) == tutorial_title && line.substr(post_title_pos, 1) == str(current_index)):
			# read following lines
			line = file.get_line()
			while(line.length() > 0):
				content += (line + '\n')
				line = file.get_line()
			
			file.close()
			return content
	
	file.close()
	return null

func _on_Button_pressed():
	next_page()
