extends Button

onready var hp_bar = $HBoxContainer/VBoxContainer/HPBar

onready var popup = $PopupMenu
var popup_rect

func _ready():
	popup_rect = popup.get_rect()
	popup_rect.position.x = get_rect().position.x + get_rect().size.x
	popup_rect.position.y = get_rect().position.y

func _pressed():
	popup.popup(popup_rect)

func set_data(unit):
	set_disabled(false)
	
	$HBoxContainer.show()
	$HBoxContainer/VBoxContainer/HBoxContainer/Name.set_text(unit.get_name())
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
	
	$HBoxContainer/VBoxContainer/HP.set_text(txt_cur_hp + "/" + txt_max_hp)
