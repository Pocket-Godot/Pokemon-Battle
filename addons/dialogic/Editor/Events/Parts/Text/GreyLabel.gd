@tool
extends Label

func _ready():
	add_theme_color_override("font_color", get_color("contrast_color_2", "Editor"))
