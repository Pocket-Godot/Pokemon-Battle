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
const IMG_EXTS = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]
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
		var full_path = get_item_tooltip(index)
		set_tooltip(full_path)
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
				go_through_folder_for_options(main_dir, dir)
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
			var filepath = data["files"][0]
			set_by_filepath(filepath)
			emit_signal("resource_is_set", get_parent(), filepath)

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
		else:
			var file_ext = file_name.get_extension()
			var full_filename = file_name
			if base_folder:
				full_filename = base_folder.plus_file(file_name)
			var has_entry = true
			
			# IF FILE IS AN IMAGE
			if file_ext in IMG_EXTS:
				var img_txt = get_image_texture(full_filename)
				
				get_popup().add_icon_item(img_txt, "", main_screen.OPT_INSTALOAD)
			
			# ELSE, IF FILE IS A RESOURCE
			elif file_ext in RES_EXTS:
				get_popup().add_item(file_name, main_screen.OPT_INSTALOAD)
				
			else:
				has_entry = false
				
			# ADD FULL FILEPATH TO TOOLTIP
			if has_entry:
				var last_index = get_popup().get_item_count() - 1
				get_popup().set_item_tooltip(last_index, full_filename)
		
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

func get_image_texture(full_filename)->ImageTexture:
	var img_txt = ImageTexture.new()
	var res_img = load(full_filename)
	var image: Image = res_img.get_data()
	img_txt.create_from_image(image)
	
	# SCALE IMAGE TEXTURE TO x0.75 WIDTH OF OPTION BUTTON
	var new_width = get_global_rect().size.x * 0.75
	if image.get_width() > new_width:
		var new_height = image.get_height() / image.get_width() * new_width
		img_txt.set_size_override(Vector2(new_width, new_height))
				
	return img_txt

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
			if extension in IMG_EXTS:
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

func set_by_filepath(full_path):
	var ext = full_path.get_extension()
						
	if ext in IMG_EXTS:
		set_img(full_path)
		set_text("")
	else:
		var res_name = full_path.rsplit("/")[-1]
		set_text(res_name)
		
	set_tooltip(full_path)

func set_dragdata(data):
	drag_data = data
	update()

func set_img(string):
	set_button_icon(get_image_texture(string))

func setup_default_options():
	var popup:PopupMenu = get_popup()
	var editor_control = editor_plugin.get_editor_interface().get_base_control()
	
	var icon_load = editor_control.get_icon("Load", "EditorIcons")
	popup.add_icon_item(icon_load, "Load", main_screen.OPT_LOAD)
	
	popup.add_separator()
	
	main_screen.add_options_to_popup(popup)
