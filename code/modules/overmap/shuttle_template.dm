/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/port_id
	var/shuttle_id = "SHOULD NEVER EXIST"

	var/description
	var/prerequisites
	var/admin_notes

	var/list/movement_force // If set, overrides default movement_force on shuttle

	var/port_x_offset
	var/port_y_offset


/datum/map_template/shuttle/proc/prerequisites_met()
	return TRUE

/datum/map_template/shuttle/New()
	if(shuttle_id == "SHOULD NEVER EXIST")
		stack_trace("invalid shuttle datum")
	return ..()

/datum/map_template/shuttle/load(turf/T, centered, register=TRUE)
	. = ..()
	if(!.)
		return
	var/list/turfs = block(locate(.[MAP_MINX], .[MAP_MINY], .[MAP_MINZ]),
							locate(.[MAP_MAXX], .[MAP_MAXY], .[MAP_MAXZ]))
	for(var/i in 1 to turfs.len)
		var/turf/place = turfs[i]
		if(istype(place, /turf/environment/space)) // This assumes all shuttles are loaded in a single spot then moved to their real destination.
			continue
		if(length(place.baseturfs) < 2) // Some snowflake shuttle shit
			continue
		place.baseturfs.Insert(3, /turf/baseturf_skipover/shuttle)

		for(var/obj/docking_port/mobile/port in place)
			if(register)
				port.register()
			if(isnull(port_x_offset))
				continue
			switch(port.dir) // Yeah this looks a little ugly but mappers had to do this in their head before
				if(NORTH)
					port.width = width
					port.height = height
					port.dwidth = port_x_offset - 1
					port.dheight = port_y_offset - 1
				if(EAST)
					port.width = height
					port.height = width
					port.dwidth = height - port_y_offset
					port.dheight = port_x_offset - 1
				if(SOUTH)
					port.width = width
					port.height = height
					port.dwidth = width - port_x_offset
					port.dheight = height - port_y_offset
				if(WEST)
					port.width = height
					port.height = width
					port.dwidth = port_y_offset - 1
					port.dheight = width - port_x_offset
