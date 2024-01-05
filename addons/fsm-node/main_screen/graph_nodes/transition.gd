@tool
class_name GraphTransition extends CompGraphElement

var left: float:
	set(val):
		left = val
		get_material().set_shader_parameter("left", val)
		
var leftest: float

var right: float:
	set(val):
		right = val
		get_material().set_shader_parameter("right", val)
		
var rightest: float

var up: float
var down: float

func _has_point(point)-> bool:
	var mouse_posx = point.x
	var mouse_posy = point.y
	
	if mouse_posx > leftest and mouse_posx < rightest:
		var final_hover = mouse_posx <= left or mouse_posx >= right
		
		if final_hover:
			connection_is_right = mouse_posx > 0
			
			var pos_from_cor = abs(point) - Vector2(right, 0)
			var opp_y = down - pos_from_cor.y
			final_hover = pos_from_cor.y < down and opp_y > pos_from_cor.x
			
			hover_over_connection = final_hover
			return hover_over_connection
		
		else:
			hover_over_connection = final_hover
			return mouse_posy > up and mouse_posy < down
	
	else:
		return false


func draw_frame(size):
	var half_width = size.x / 2
	var half_height = size.y / 2
	half_height += get_theme_constant("border_margin", THEME_TYPE)
	get_material().set_shader_parameter("side_width", half_height)
	
	right = half_width
	rightest = right + half_height
	left = -right
	leftest = left - half_height
	
	down = half_height
	up = -down
	
	var points = [
		Vector2(leftest, 0),
		Vector2(left, up),
		Vector2(right, up),
		Vector2(rightest, 0),
		Vector2(right, down),
		Vector2(left, down),
	]
	
	draw_colored_polygon(points, Color.BLACK)
	
	points.append(points[0])
	draw_polyline(points, get_border_color(), get_theme_constant("border_width", THEME_TYPE))
