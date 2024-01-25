extends RichTextLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#var dynamic_font = DynamicFont.new()
	#dynamic_font.font_data = load("res://DinoCrush.ttf")
	#dynamic_font.size = 64
	var dynamic_font = load("res://DinoCrush.tres")
	set("custom_fonts/font", dynamic_font)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
