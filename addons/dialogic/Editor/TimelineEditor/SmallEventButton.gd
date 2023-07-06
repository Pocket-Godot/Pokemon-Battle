@tool
extends Button

@export var visible_name: String = ""
@export (String) var event_id = 'dialogic_099'
@export (Color) var event_color = Color('#48a2a2a2')
@export var event_icon: Texture2D = null: set = set_icon
@export (int) var event_category := 0
@export (int) var sorting_index := 0
var editor_reference

func _ready():
	editor_reference = find_parent('EditorView')
	self_modulate = Color(1,1,1)
	if visible_name != '':
		text = visible_name
	tooltip_text = editor_reference.dialogicTranslator.translate(tooltip_text)
	var _scale = DialogicUtil.get_editor_scale(self)
	custom_minimum_size = Vector2(30,30)
	custom_minimum_size = custom_minimum_size * _scale
	icon = null
	var t_rect = $TextureRect
	var c_border = $ColorBorder
	c_border.self_modulate = event_color
	c_border.custom_minimum_size.x = 5 * _scale
	c_border.size.x = 5 * _scale
	t_rect.offset_left = 18 * _scale
	# Another programming crime was commited
	# a switch statement is missing
	# what a horrible sight
	# elif I have you on my mind
	if _scale == 2 or _scale == 1.75:
		t_rect.scale = Vector2(1, 1)
	elif _scale == 1.5:
		t_rect.scale = Vector2(0.8, 0.8)
	elif _scale == 0.75:
		t_rect.scale = Vector2(0.4, 0.4)
	else:
		t_rect.scale = Vector2(0.6, 0.6)
	
	add_theme_color_override("font_color", get_color("font_color", "Editor"))
	add_theme_color_override("font_color_hover", get_color("accent_color", "Editor"))
	t_rect.modulate = get_color("font_color", "Editor")


func set_icon(texture):
	#icon = texture
	event_icon = texture
	var _scale = DialogicUtil.get_editor_scale(self)
	$TextureRect.texture = texture


func _get_drag_data(position):
	var preview_label = Label.new()
	
	if (self.text != ''):
		preview_label.text = text
	else:
		preview_label.text = 'Add Event %s' % [ tooltip_text ]
		
	set_drag_preview(preview_label)
	
	return { "source": "EventButton", "event_id": event_id }
