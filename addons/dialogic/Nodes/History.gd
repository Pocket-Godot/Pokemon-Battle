@tool
extends Control


@export var HistoryRow: PackedScene = load("res://addons/dialogic/Example Assets/History/HistoryRow.tscn")
@export var HistoryDefaultBackground: PackedScene = load("res://addons/dialogic/Example Assets/History/HistoryBackground.tscn")
@export var HistoryOpenButton: PackedScene = load("res://addons/dialogic/Example Assets/History/HistoryButton.tscn")
@export var HistoryCloseButton: PackedScene = load("res://addons/dialogic/Example Assets/History/HistoryButton.tscn")
@export var Vertical_Separation: int = 16

@onready var HistoryTimeline = $HistoryPopup/ScrollHistoryContainer/MarginContainer/HistoryTimeline
@onready var scrollbar = $HistoryPopup/ScrollHistoryContainer.get_v_scroll_bar()
@onready var ScrollHistoryContainer = $HistoryPopup/ScrollHistoryContainer
@onready var HistoryPopup = $HistoryPopup
@onready var HistoryAudio = $HistoryPopup/HistoryAudio

var HistoryButton 
var CloseButton
var HistoryBackground

var is_history_open = false
var is_mouse_on_button = false
var block_dialog_advance = false: get = history_advance_block

var lastQuestionNode = null
var curTheme = null
var prevState

var eventsToLog = ['dialogic_001', 'dialogic_010'] 
var logArrivals = false
var logExits = false

var scrollToBottom = true
var reverseTimeline = false
var characterNameColorOn = true
var lineBreakAfterName = true

var scrollToggle = false

func _ready():
	var testHistoryRow = HistoryRow.instantiate()
	assert(testHistoryRow.has_method('add_history')) #,'HistoryRow Scene must implement add_history(string, string) method.')
	testHistoryRow.queue_free()
	
	HistoryBackground = HistoryDefaultBackground.instantiate()
	HistoryPopup.add_child(HistoryBackground)
	HistoryPopup.move_child(HistoryBackground, 0)
	
	#Scrollbar only updates when visible, so need it to be handled
	scrollbar.connect("changed", Callable(self, "handle_scrollbar_changed"))
	
func handle_scrollbar_changed():
	#It's firing every frame, we only want to check it once on opening 
	if(scrollToggle):
		scrollToggle = false
		if (scrollToBottom):
			ScrollHistoryContainer.scroll_vertical = scrollbar.max_value
		else:
			ScrollHistoryContainer.scroll_vertical = 0


func initalize_history():
	if get_parent().settings.get_value('history', 'enable_open_button', true):
		HistoryButton = HistoryOpenButton.instantiate()
		add_child(HistoryButton)
		HistoryButton.connect("pressed", Callable(self, '_on_toggle_history'))
		HistoryButton.connect("mouse_entered", Callable(self, '_on_HistoryButton_mouse_entered'))
		HistoryButton.connect("mouse_exited", Callable(self, '_on_HistoryButton_mouse_exited'))
		HistoryButton.disabled = false
		HistoryButton.show()
	
	if get_parent().settings.get_value('history', 'enable_close_button', true):
		CloseButton = HistoryCloseButton.instantiate()
		add_child(CloseButton)
		CloseButton.connect("pressed", Callable(self, '_on_toggle_history'))
		CloseButton.disabled = true
		CloseButton.hide()
	
	# See if we're logging arrivals and exits
	logArrivals = get_parent().settings.get_value('history', 'log_arrivals', true)
	logExits = get_parent().settings.get_value('history', 'log_exits', true)
	if logExits or logArrivals:
		eventsToLog.push_back('dialogic_002')
		
	# Set the other selectable settings options
	scrollToBottom = get_parent().settings.get_value('history', 'history_scroll_to_bottom', true)
	reverseTimeline = get_parent().settings.get_value('history', 'history_reverse_timeline', false)
	characterNameColorOn = get_parent().settings.get_value('history', 'history_name_color_on', true)
	lineBreakAfterName = get_parent().settings.get_value('history', 'history_break_after_name', false)
	
	
	# Grab some settings and make the boxes up right
	var button_anchor = int(get_parent().settings.get_value('history', 'history_button_position', 2))
	var screen_margin_x = get_parent().settings.get_value('history', 'history_screen_margin_x', 0)
	var screen_margin_y = get_parent().settings.get_value('history', 'history_screen_margin_y', 0)
	var container_margin_X = get_parent().settings.get_value('history', 'history_container_margin_x', 0)
	var container_margin_y = get_parent().settings.get_value('history', 'history_container_margin_y', 0)
	
	HistoryPopup.offset_left = screen_margin_x
	HistoryPopup.offset_right = -screen_margin_x
	HistoryPopup.offset_top = screen_margin_y
	HistoryPopup.offset_bottom = -screen_margin_y
	
	ScrollHistoryContainer.offset_left = container_margin_X
	ScrollHistoryContainer.offset_right = -container_margin_X
	ScrollHistoryContainer.offset_top = container_margin_y
	ScrollHistoryContainer.offset_bottom = -container_margin_y
	
	for button in [HistoryButton, CloseButton]:
		if button == null:
			continue
		
		var reference = button.get_parent().size
		
		# Adding audio when focused or hovered
		button.connect('focus_entered', Callable(get_parent(), '_on_option_hovered').bind(button))
		button.connect('mouse_entered', Callable(get_parent(), '_on_option_focused'))
		
		# Button positioning
		var anchor_values = [0,0,1,1]
		var position_offset = Vector2(0,0)
		
		# Top Left
		if button_anchor == 0:
			anchor_values = [0, 0, 0, 0]
			position_offset.x = 0
			position_offset.y = 0
		# Top Center
		elif button_anchor == 1:
			anchor_values = [.5, 0, .5, 0]
			position_offset.x = reference.x/2 - button.size.x
			position_offset.y = 0
		# Top Right
		elif button_anchor == 2:
			anchor_values = [1, 0, 1, 0]
			position_offset.x = reference.x - button.size.x
			position_offset.y = 0
		# 3 - Number skip because of the separator
		# Center Left
		elif button_anchor == 4:
			anchor_values = [0, .5, 0, .5]
			position_offset.x = 0
			position_offset.y = reference.y/2 - button.size.y
		# True Center
		elif button_anchor == 5:
			anchor_values = [.5, .5, .5, .5]
			position_offset.x = reference.x/2 - button.size.x
			position_offset.y = reference.y/2 - button.size.y
		# Center Right
		elif button_anchor == 6:
			anchor_values = [1, .5, 1, .5]
			position_offset.x = reference.x - button.size.x
			position_offset.y = reference.y/2 - button.size.y
		# Number skip because of the separator
		elif button_anchor == 8:
			anchor_values = [0, 1, 0, 1]
			position_offset.x = 0
			position_offset.y = reference.y - button.size.y
		elif button_anchor == 9:
			anchor_values = [.5, 1, .5, 1]
			position_offset.x = reference.x/2 - button.size.x
			position_offset.y = reference.y - button.size.y
		elif button_anchor == 10:
			anchor_values = [1, 1, 1, 1]
			position_offset.x = reference.x - button.size.x
			position_offset.y = reference.y - button.size.y
		
		button.anchor_left = anchor_values[0]
		button.anchor_top = anchor_values[1]
		button.anchor_right = anchor_values[2]
		button.anchor_bottom = anchor_values[3]
		
		button.global_position = button.get_parent().global_position + position_offset


# Add history based on the passed event, using some logic to get it right
func add_history_row_event(eventData):
	# Abort if we aren't logging the event, or if its a character event of type update
	if !eventsToLog.has(eventData.event_id) or (eventData.event_id == 'dialogic_002' and eventData.get('type') == 2 ):
		return
	# Abort if we aren't logging arrivals and its a character event of type arrival
	if eventData.event_id == 'dialogic_002' and eventData.get('type') == 0 and !logArrivals:
		return
	# Abort if we aren't logging exits and its a character event of type exit
	if eventData.event_id == 'dialogic_002' and eventData.get('type') == 1 and !logExits:
		return
	
	var newHistoryRow = HistoryRow.instantiate()
	HistoryTimeline.add_child(newHistoryRow)
	if(reverseTimeline):
		HistoryTimeline.move_child(newHistoryRow,0)
	if newHistoryRow.has_method('load_theme') and get_parent().settings.get_value('history', 'enable_dynamic_theme', false) == true:
		newHistoryRow.load_theme(curTheme)
	
	var characterPrefix = ''
	if eventData.has('character') and eventData.character != '':
		var characterData = DialogicUtil.get_character(eventData.character)
		var characterName = characterData.get('name', '')
		if eventData.has('character') and eventData.character == '[All]':
			characterPrefix = str('Everyone')
		elif characterData.data.get('display_name_bool', false)  == true:
			characterName = characterData.data.get('display_name', '')
		
		if characterName != '':
			var charDelimiter = get_parent().settings.get_value('history', 'history_character_delimiter', '')
			var parsed_name = DialogicParser.parse_definitions(get_parent(), characterName, true, false)
			var characterColor = characterData.data.get('color', Color.WHITE)
			if (!characterNameColorOn):
				characterColor = Color.WHITE
			var lineBreak = '' 
			if (lineBreakAfterName):
				lineBreak = '\n'
			characterPrefix = str("[color=",characterColor,"]", parsed_name, "[/color]", charDelimiter, ' ', lineBreak)
	
	var audioData = ''
	if eventData.has('voice_data'):
		if eventData['voice_data'].has('0'):
			audioData = eventData['voice_data']['0'].file
			newHistoryRow.AudioButton.connect('pressed', Callable(self, '_on_audio_trigger').bind(audioData))
	
	
	# event logging handled here
	# Text Events
	if eventData.event_id == 'dialogic_001':
		newHistoryRow.add_history(str(characterPrefix, eventData.text), audioData)
	# Character Arrivals
	elif eventData.event_id == 'dialogic_002':
		var logText = get_parent().settings.get_value('history', 'text_arrivals', 'has arrived')
		if eventData.get('type') == 1:
			 logText = get_parent().settings.get_value('history', 'text_exits', 'has left')
		newHistoryRow.add_history(str(characterPrefix, ' ', logText), audioData)
	# List Choices
	elif eventData.event_id == 'dialogic_010':
		newHistoryRow.add_history(str(characterPrefix, eventData.question), audioData)
		if eventData.has('options') and get_parent().settings.get_value('history', 'log_choices', true):
			var choiceString = "\n\t"
			for choice in eventData['options']:
				choiceString = str(choiceString, '[', choice.label, ']\t')
			newHistoryRow.add_history(choiceString, audioData)
		lastQuestionNode = newHistoryRow


func add_answer_to_question(stringData):
	if lastQuestionNode != null:
		lastQuestionNode.add_history(str('\n\t', stringData), lastQuestionNode.audioPath)
		lastQuestionNode = null


func change_theme(newTheme: ConfigFile):
	if get_parent().settings.get_value('history', 'enable_dynamic_theme', false):
		curTheme = newTheme


func load_theme(theme: ConfigFile):
	curTheme = theme


func _on_audio_trigger(audioFilepath):
	HistoryAudio.stream = load(audioFilepath)
	HistoryAudio.play()


func _on_HistoryPopup_popup_hide():
	HistoryAudio.stop()


func _on_HistoryPopup_about_to_show():
	if HistoryButton != null:
		scrollToggle = true
		HistoryButton.show()



func _on_HistoryButton_mouse_entered():
	is_mouse_on_button = true


func _on_HistoryButton_mouse_exited():
	is_mouse_on_button = false


func history_advance_block() -> bool:
	return is_mouse_on_button or is_history_open 

# Used to manually toggle the history visibility on or off
# This is most useful when you wish to make your own custom controls
func _on_toggle_history():
	if HistoryPopup.visible == false:
		_on_HistoryPopup_about_to_show()
		HistoryPopup.show()
		if HistoryButton != null:
			HistoryButton.hide()
			HistoryButton.disabled = true
		if CloseButton != null:
			CloseButton.disabled = false
			CloseButton.show()
		is_history_open = true
		is_mouse_on_button = false
	else:
		_on_HistoryPopup_popup_hide()
		HistoryPopup.hide()
		if HistoryButton != null:
			HistoryButton.show()
			HistoryButton.disabled = false
		if CloseButton != null:
			CloseButton.disabled = true
			CloseButton.hide()
		is_history_open = false
		is_mouse_on_button = false


