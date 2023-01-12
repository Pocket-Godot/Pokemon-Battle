extends MarginContainer

onready var hp_bar = $MarginContainer/HBoxContainer/VBoxContainer/HPBar
onready var hp_txt = $MarginContainer/HBoxContainer/VBoxContainer/HP

onready var popup = $Button/PopupMenu
var popup_rect

func _ready():
	popup_rect = popup.get_rect()
	popup_rect.position.x = get_rect().position.x + get_rect().size.x
	popup_rect.position.y = get_rect().position.y

func _on_btn_pressed():
	popup.popup(popup_rect)

func set_data(unit):
	$Button.set_disabled(false)
	
	$MarginContainer.show()
	$MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Name.set_text(unit.get_name())
	set_health(unit.hp, unit.hp)
	
func set_health(max_hp, cur_hp):
	hp_bar.set_max(max_hp)
	set_cur_hp(cur_hp)
	
func set_cur_hp(hp):
	hp_bar.set_value(hp)
	set_hp_text()
	
func set_hp_text():
	var txt_max_hp = String(hp_bar.get_max())
	var txt_cur_hp = String(hp_bar.get_value())
	
	hp_txt.set_text(txt_cur_hp + "/" + txt_max_hp)

func connect_popup(n, i):
	popup.connect("index_pressed", n, "_on_switch_popmenu_pressed", [i])

func disable_switch_option():
	popup.set_item_disabled(1, true)
