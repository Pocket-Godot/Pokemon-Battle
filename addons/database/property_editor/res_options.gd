tool
extends OptionButton

const NULL_VALUE_TEXT = "[empty]"

var editor_plugin
var main_screen
var empty_options
var empty_wcat
var resource_options # THE POPUP, NOT SELF

var drag_data
var class_hint = "Resource"

onready var cat_filesystem = get_parent().get_node("ChooseCat")

const RES_EXTS = ["res", "tres"]
signal resource_is_set

func _draw():
	if is_compatable_with_drag():
		var rect2_pos = get_parent().get_parent().get_position()
		var rect2 = Rect2(rect2_pos, get_size())
		var hover_border = editor_plugin.get_editor_interface().get_editor_settings().get_setting("interface/theme/accent_color")
		draw_rect(rect2, hover_border, false)

func _editor_plugin_is_set():
	editor_plugin = get_parent().editor_plugin
	main_screen = editor_plugin.main_panel_instance
	empty_options = main_screen.empty_options
	empty_wcat = main_screen.empty_wcat
	resource_options = main_screen.resource_options

func _gui_input(event):
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_RIGHT and event.is_pressed():
		var mouse_pos = event.get_global_position()
		
		main_screen.selected_resoptions = self
		var options
		if get_text() == NULL_VALUE_TEXT:
			var value = get_parent().resource_container.associated_resource.get(get_parent().property_name)
			if main_screen.DATA_DIR in get_category_folder():
				options = empty_wcat
			else:
				options = empty_options
		else:
			options = resource_options
		
		options.popup(Rect2(mouse_pos, options.get_size()))

func _item_selected(index:int):
	var id = get_item_id(index)
	
	if id == main_screen.OPT_INSTALOAD:
		#SETTING A RESOURCE
		var file_name = get_item_text(index)
		var full_path = get_category_folder().plus_file(file_name)
		emit_signal("resource_is_set", get_parent(), full_path)
	else:
		main_screen.item_id_effect(self, id)
		reset_text()

func can_drop_data(_p, _d):
	return is_compatable_with_drag()

func change_options(dir):
	get_popup().clear()
	
	cat_filesystem.set_current_dir(dir)
	
	if dir == "res://":
		setup_default_options()
		get_popup().set_allow_search(false)
	else:
		get_popup().set_allow_search(true)
		
		var main_dir = Directory.new()
		var err = main_dir.open(dir)
		
		match err:
			OK:
				go_through_folder_for_options(main_dir)
			_:
				print(err)

func clear_value():
	set_text(NULL_VALUE_TEXT)
	emit_signal("resource_is_set", get_parent(), "")

func drop_data(_p, data):
	#print(data)
	match data["type"]:
		"files_and_dirs":
			get_parent().resource_container.augment_config(get_property_name(), data["files"][0])
			change_options(data["files"][0])
		"files":
			set_text(data["files"][0].get_file())
			emit_signal("resource_is_set", get_parent(), data["files"][0])

func go_through_folder_for_options(dir:Directory, base_folder:String = ""):
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while file_name != "":
		
		# IF THE ITEM IS A FOLDER
		if dir.current_is_dir():
			var sub_directory = Directory.new()
			sub_directory.open(dir.get_current_dir().plus_file(file_name))
			var folder = file_name
			if base_folder:
				folder = base_folder.plus_file(file_name)
			go_through_folder_for_options(sub_directory, folder)
		
		# ELSE, IF ITEM IS A FILE
		elif file_name.get_extension() in RES_EXTS:
			var final_filename = file_name
			if base_folder:
				final_filename = base_folder.plus_file(file_name)
			get_popup().add_item(final_filename, main_screen.OPT_INSTALOAD)
		
		file_name = dir.get_next()
		
	dir.list_dir_end()

func get_category_folder():
	return cat_filesystem.get_current_dir()

func get_icon_name(cn)->String:
	match cn:
		"Resource":
			return "ResourcePreloader"
		"Texture":
			return "Image"
		_:
			return cn

func get_property_name():
	return get_parent().property_name

func is_compatable_with_drag():
	#print(drag_data)
	if drag_data:
		match drag_data["type"]:
			"files_and_dirs":
				return true
			"files":
				return is_compatable_with_file(drag_data["files"][0])
			
	return false

func is_compatable_with_file(file):
	var extension = file.get_extension()
	
	match class_hint:
		"Texture":
			if extension in ["png", "jpeg", "svg"]:
				return true
		_:
			if extension in RES_EXTS:
				return true
		
	return false

func reset_text():
	var final_text
	
	var value = get_parent().resource_container.get(get_parent().property_name)
	if value:
		final_text = value.get_path().rsplit("/")[-1]
	else:
		final_text = NULL_VALUE_TEXT
	
	set_button_icon(null)
	set_text(final_text)

func set_dragdata(data):
	drag_data = data
	update()

func setup_default_options():
	var popup:PopupMenu = get_popup()
	var editor_control = editor_plugin.get_editor_interface().get_base_control()
	
	var icon_load = editor_control.get_icon("Load", "EditorIcons")
	popup.add_icon_item(icon_load, "Load", main_screen.OPT_LOAD)
	
	popup.add_separator()
	
	main_screen.add_options_to_popup(popup)
