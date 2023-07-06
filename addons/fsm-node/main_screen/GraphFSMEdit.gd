@tool
extends GraphEdit

var associated_fsm
var title

func _on_connection_request(str_from, from_port, str_to, to_port):
	
	# IF THE CONNECTION IS NOT ALREADY MADE
	if !is_node_connected(str_from, from_port, str_to, to_port):
		var gn_from = get_node(str_from)
		var gn_to = get_node(str_to)
		var nd_from = gn_from.associated_component
		
		var connection_type = gn_from.get_connection_output_type(0)
		if connection_type == 1:
			# STATE TO TRANSITION
			
			#	GET RELATIVE NODEPATH
			var target_np = nd_from.get_path_to(gn_to.associated_component)
			
			#	IF THE CONNECTION IS SUCESSFULLY MADE,
			if connect_node(str_from, from_port, str_to, to_port) == OK:
				# ADD TRANSITION TO THE LIST
				nd_from.transitions += [target_np]
						
				# UPDATE PROPERTY LIST
				nd_from.notify_property_list_changed()
		else:
			# TRANSITION TO STATE
			
			#	FOR EVERY CONNECTIONS
			for c in get_connection_list():
				# IF FROM SIDE IS THE SAME
				if c["from"] == str_from:
					
					# DISCONNECT FROM THAT NODE
					_on_disconnection_request(c["from"], c["from_port"], c["to"], c["to_port"])
					
			#	IF THE CONNECTION IS SUCESSFULLY MADE,
			if connect_node(str_from, from_port, str_to, to_port) == OK:
				# SET TARGET STATE
				nd_from.target_state = nd_from.get_path_to(gn_to.associated_component)
				
				# UPDATE PROPERTY LIST
				nd_from.notify_property_list_changed()

func _on_disconnection_request(str_from, from_port, str_to, to_port):
	disconnect_node(str_from, from_port, str_to, to_port)
	
	var gn_from = get_node(str_from)
	var nd_from = gn_from.associated_component
	var connection_type = gn_from.get_connection_output_type(0)
	if connection_type == 1:
		# STATE TO TRANSITION
		var gn_to = get_node(str_to)
		var nd_to = gn_to.associated_component
		#	GET RELATIVE NODEPATH
		var target_np = nd_from.get_path_to(nd_to)
		nd_from.transitions.erase(target_np)
	else:
		# TRANSITION TO STATE
		nd_from.target_state = null
		
	# UPDATE PROPERTY LIST
	nd_from.notify_property_list_changed()
	
func set_associated_fsm(node):
	associated_fsm = node
