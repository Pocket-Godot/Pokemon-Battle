tool
extends Resource

export (Color) var color
export (Texture) var default_palette

export (Dictionary) var defensive_effectivenesses

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
