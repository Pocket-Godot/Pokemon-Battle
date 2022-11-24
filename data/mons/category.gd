extends Resource

export(Texture) var front
export(Texture) var back

export(Resource) var type1
export(Resource) var type2

export(Resource) var move1
export(Resource) var move2
export(Resource) var move3
export(Resource) var move4

export(int) var hp := 10

func get_name()->String:
	return resource_path.get_file().get_basename().capitalize()
