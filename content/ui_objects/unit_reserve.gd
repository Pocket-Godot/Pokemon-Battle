extends Button

onready var popup = $PopupMenu
var popup_rect

func _ready():
	popup_rect = popup.get_rect()
	popup_rect.position.x = get_rect().position.x + get_rect().size.x
	popup_rect.position.y = get_rect().position.y

func _pressed():
	popup.popup(popup_rect)
