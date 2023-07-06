@tool
extends PanelContainer

@onready var nodes = {
	'title': $VBoxContainer/Title,
	'body': $VBoxContainer/Content,
	'extra': $VBoxContainer/Extra,
}

var in_theme_editor = false
var margin = 10


func _ready():
	set_deferred('size.y', 0)
	nodes['title'].bbcode_enabled = true
	nodes['body'].bbcode_enabled = true
	nodes['extra'].bbcode_enabled = true


func _process(_delta):
	if Engine.is_editor_hint() == false or in_theme_editor == true:
		if visible:
			if get_global_mouse_position().x < get_viewport().size.x * 0.5:
				global_position = get_global_mouse_position() - Vector2(0, size.y + (margin * 2))
			else:
				global_position = get_global_mouse_position() - size - Vector2(0, (margin * 2))
			size.y = 0
#			

func load_preview(info):
	nodes['title'].visible = false
	nodes['body'].visible = false
	nodes['extra'].visible = false
	
	if info['title'] != '':
		nodes['title'].text = info['title']
		nodes['title'].visible = true

	if info['body'] != '':
		nodes['body'].text = info['body']
		nodes['body'].visible = true
	
	if info['extra'] != '':
		nodes['extra'].text = info['extra']
		nodes['extra'].visible = true


func load_theme(theme):
	# Fonts
	$VBoxContainer/Title.set(
		'theme_override_fonts/normal_font', 
		DialogicUtil.path_fixer_load(theme.get_value('definitions', 'font', "res://addons/dialogic/Example Assets/Fonts/GlossaryFont.tres")))
	$VBoxContainer/Title.set('theme_override_colors/default_color', theme.get_value('definitions', 'title_color', "#ffffffff"))
	
	$VBoxContainer/Content.set(
		'theme_override_fonts/normal_font', 
		DialogicUtil.path_fixer_load(theme.get_value('definitions', 'text_font', "res://addons/dialogic/Example Assets/Fonts/GlossaryFont.tres")))
	$VBoxContainer/Content.set('theme_override_colors/default_color', theme.get_value('definitions', 'text_color', "#c1c1c1"))
	
	$VBoxContainer/Extra.set(
		'theme_override_fonts/normal_font', 
		DialogicUtil.path_fixer_load(theme.get_value('definitions', 'extra_font', "res://addons/dialogic/Example Assets/Fonts/GlossaryFont.tres")))
	$VBoxContainer/Extra.set('theme_override_colors/default_color', theme.get_value('definitions', 'extra_color', "#c1c1c1"))
	
	set("theme_override_styles/panel", load(theme.get_value('definitions', 'background_panel', "res://addons/dialogic/Example Assets/backgrounds/GlossaryBackground.tres")))
