/obj/docking_port/stationary
	name = "dock"

	var/last_dock_time

	var/datum/map_template/shuttle/roundstart_template
	///An optional specific id for the roundstart template, if you don't want the procedural made one
	var/roundstart_shuttle_specific_id = ""
	var/json_key
	///The ID of the shuttle reserving this dock.
	var/reservedId = null

/obj/docking_port/stationary/proc/load_roundstart()
	if(roundstart_template)
		var/sid = "[initial(roundstart_template.shuttle_id)]"

		roundstart_template = shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("Invalid path ([roundstart_template]) passed to docking port.")

	if(roundstart_template)
		SSshuttle.action_load(roundstart_template, src)

/obj/docking_port/stationary/register(replace = FALSE)
	. = ..()
	if(!id)
		id = "dock"
	else
		port_destinations = id

	if(!name)
		name = "dock"

	var/counter = SSshuttle.assoc_stationary[id]
	if(!replace || !counter)
		if(counter)
			counter++
			SSshuttle.assoc_stationary[id] = counter
			id = "[id]_[counter]"
			name = "[name] [counter]"
		else
			SSshuttle.assoc_stationary[id] = 1

	if(!port_destinations)
		port_destinations = id

	SSshuttle.stationary += src

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	. = locate(/obj/docking_port/mobile) in loc