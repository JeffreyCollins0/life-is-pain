extends Node2D

export (float) var lifespan = 1.0
export (float) var move_speed = 0.4
const positive_color = Color(0.26, 0.83, 0.31, 1.0)
const negative_color = Color(0.96, 0.27, 0.27, 1.0)

var actual_lifespan = 1.6
var saved_color = Color(0.0, 0.0, 0.0, 1.0)

func _ready():
	actual_lifespan = lifespan

func _process(delta):
	if(actual_lifespan > 0):
		actual_lifespan -= delta
		
		position += (Vector2.UP * move_speed)
		
		var current_color = Color(saved_color.r, saved_color.g, saved_color.b, (actual_lifespan / lifespan) )
		$Label.add_color_override("font_color", current_color)
		
		if(actual_lifespan <= 0):
			queue_free()

func init(amount):
	if(amount != 0):
		var sign_str = '-' if (amount < 0) else '+'
		saved_color = negative_color if (amount < 0) else positive_color
		$Label.text = (sign_str + str(amount) + '%')
		$Label.add_color_override("font_color", saved_color)
