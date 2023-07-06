@tool
extends Resource

@export var color: Color
@export var default_palette: Texture2D
@export_file("*.tscn") var fp_hit_effect: String

@export var defensive_effectivenesses: Dictionary

func get_def_eff(key_type)->float:
	if defensive_effectivenesses.has(key_type):
		return defensive_effectivenesses[key_type]
	else:
		return 1.0

func get_key():
	return get_path().get_file().get_basename()

func get_keyname():
	var short_base := get_path().get_file().get_basename()
	
	return "NAME_TYPE_" + short_base.to_upper()
