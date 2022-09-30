tool
extends VBoxContainer

var listgrid
var index

enum {DT_NULL, DT_BOOL, DT_INT, DT_FLOAT, DT_STRING, DT_COLOR}
var datatypes = { TYPE_NIL: DT_NULL,
	TYPE_BOOL: DT_BOOL,
	TYPE_INT: DT_INT,
	TYPE_REAL: DT_FLOAT,
	TYPE_STRING: DT_STRING,
	TYPE_COLOR: DT_COLOR }
var prev_datatype = DT_NULL

onready var input_string = $LineEdit
onready var input_bool = $CheckBox
onready var input_number = $SpinBox
onready var input_color = $ColorPickerButton

signal value_changed

func _listgrid_call_itemchange(lg):
	listgrid = lg
	connect("value_changed", listgrid, "_on_value_changed")

func _listgrid_call_keychange(lg):
	listgrid = lg
	connect("value_changed", listgrid, "_on_key_changed")
	connect("value_changed", self, "_on_key_changed")
	connect("value_changed", get_parent(), "_on_key_changed")

func _key(k):
	# REUSE INDEX TO STORE PREVIOUS KEY
	set_index(k)
	set_var(k)

func _value(i, v):
	set_index(i)
	set_var(v)
	
func set_var(v):
	var opt_btn = $HBoxContainer/OptionButton
	
	opt_btn.connect("item_selected", self, "_on_datatype_selected")
	
	var type_of = typeof(v)
	var datatype = datatypes[type_of]
	opt_btn.select(datatype)
	_on_datatype_selected(datatype)
	
	match datatype:
		DT_BOOL:
			input_bool.set_pressed(v)
		DT_INT, DT_FLOAT:
			input_number.set_value(v)
		DT_STRING:
			input_string.set_text(v)
		DT_COLOR:
			input_string.set_color(v)

func _on_key_changed(v, _i, _a = null):
	set_index(v)

func set_index(i):
	index = i

func _on_datatype_selected(index):
	unset_datatype(prev_datatype)
	prev_datatype = index
	set_datatype(index)

func unset_datatype(i):
	match i:
		DT_NULL:
			input_string.hide()
		DT_BOOL:
			input_bool.hide()
			input_bool.disconnect("toggled", self, "_on_checkbox_toggled")
		DT_INT:
			input_number.hide()
			input_number.disconnect("value_changed", self, "_on_valinspinbox_changed")
		DT_FLOAT:
			input_number.hide()
			input_number.disconnect("value_changed", self, "_on_valinspinbox_changed")
		DT_STRING:
			input_string.hide()
			input_string.disconnect("text_changed", self, "_on_lineedit_changed")
		DT_COLOR:
			input_color.hide()
			input_color.disconnect("color_changed", self, "_on_colorpicker_changed")
	
func set_datatype(i):
	match i:
		DT_NULL:
			input_string.show()
			input_string.set_text("")
			input_string.set_editable(false)
		DT_BOOL:
			input_bool.show()
			
			input_bool.connect("toggled", self, "_on_checkbox_toggled")
		DT_INT:
			input_number.show()
			input_number.set_step(1)
			input_number.set_use_rounded_values(true)
			
			input_number.connect("value_changed", self, "_on_valinspinbox_changed")
		DT_FLOAT:
			input_number.show()
			input_number.set_step(0.001)
			input_number.set_use_rounded_values(false)
			
			input_number.connect("value_changed", self, "_on_valinspinbox_changed")
		DT_STRING:
			input_string.show()
			input_string.set_editable(true)
			
			input_string.connect("text_changed", self, "_on_lineedit_changed")
		DT_COLOR:
			input_color.show()
			
			input_color.connect("color_changed", self, "_on_colorpicker_changed")

func _on_checkbox_toggled(b):
	emit_signal("value_changed", b, index)
	
func _on_valinspinbox_changed(f):
	var val
	if prev_datatype == DT_INT:
		val = int(f)
	else:
		val = f
		
	emit_signal("value_changed", val, index)
	
func _on_lineedit_changed(s):
	emit_signal("value_changed", s, index)
	
func _on_colorpicker_changed(c):
	emit_signal("value_changed", c, index)
