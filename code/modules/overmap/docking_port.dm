/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonfar"

	anchored = TRUE

	/**
	  * The identifier of the port or ship.
	  * This will be used in numerous other places like the console,
	  * stationary ports and whatnot to tell them your ship's mobile
	  * port can be used in these places, or the docking port is compatible, etc.
	  */
	var/id
	///Possible destinations
	var/port_destinations
	///this should point -away- from the dockingport door, ie towards the ship
	dir = NORTH
	///size of covered area, perpendicular to dir
	var/width = 0
	///size of covered area, parallel to dir
	var/height = 0
	///position relative to covered area, perpendicular to dir
	var/dwidth = 0
	///position relative to covered area, parallel to dir
	var/dheight = 0
	var/area_type
	///are we invisible to shuttle navigation computers?
	var/hidden = FALSE
	///Delete this port after ship fly off.
	var/delete_after = FALSE
	///are we registered in SSshuttles?
	var/registered = FALSE



/obj/docking_port/proc/register()
	if(registered)
		WARNING("docking_port registered multiple times")
		unregister()
	registered = TRUE


///unregister from SSshuttles
/obj/docking_port/proc/unregister()
	if(!registered)
		WARNING("docking_port unregistered multiple times")
	registered = FALSE


//these objects are indestructible
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		..()
		. = QDEL_HINT_QUEUE
	else
		return QDEL_HINT_LETMELIVE


///Copies the width, dwidth, height and dheight value of D onto itself.
/obj/docking_port/proc/copy_size(obj/docking_port/D)
	if (!D)
		return FALSE
	width = D.width
	dwidth = D.dwidth
	height = D.height
	dheight = D.dheight
	return TRUE

//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y

	//byond's sin and cos functions are inaccurate. This is faster and perfectly accurate
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos
		)

/// Return number of turfs
/obj/docking_port/proc/return_number_of_turfs()
	var/list/L = return_coords()
	return abs((L[3]-L[1]) * (L[4]-L[2]))

///returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	return block(T0,T1)

/obj/docking_port/proc/return_center_turf()
	var/list/L = return_coords()
	var/cos = 1
	var/sin = 0
	switch(dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1
	var/_x = L[1] + (round(width/2))*cos - (round(height/2))*sin
	var/_y = L[2] + (round(width/2))*sin + (round(height/2))*cos
	return locate(_x, _y, z)

//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir)
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	for(var/dx in 0 to width-1)
		var/compX = dx-dwidth
		for(var/dy in 0 to height-1)
			var/compY = dy-dheight
			// realX = _x + compX*cos - compY*sin
			// realY = _y + compY*cos - compX*sin
			// locate(realX, realY, _z)
			var/turf/T = locate(_x + compX*cos - compY*sin, _y + compY*cos + compX*sin, _z)
			.[T] = NONE


#ifdef DOCKING_PORT_HIGHLIGHT
//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color)
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	for(var/turf/T in block(T0,T1))
		T.color = _color
		LAZYINITLIST(T.atom_colours)
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P)
		return P.id

/obj/docking_port/proc/is_in_shuttle_bounds(atom/A)
	var/turf/T = get_turf(A)
	if(T.z != z)
		return FALSE
	var/list/bounds = return_coords()
	var/x0 = bounds[1]
	var/y0 = bounds[2]
	var/x1 = bounds[3]
	var/y1 = bounds[4]
	if(!ISINRANGE(T.x, min(x0, x1), max(x0, x1)))
		return FALSE
	if(!ISINRANGE(T.y, min(y0, y1), max(y0, y1)))
		return FALSE
	return TRUE

/obj/docking_port/stationary
	name = "dock"

	var/last_dock_time

	var/datum/map_template/shuttle/roundstart_template
	///An optional specific id for the roundstart template, if you don't want the procedural made one
	var/roundstart_shuttle_specific_id = ""
	var/json_key
	///The ID of the shuttle reserving this dock.
	var/reservedId = null

/obj/docking_port/mobile
	name = "shuttle"
	icon_state = "pinonclose"

	area_type = SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE

	var/list/shuttle_areas

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/last_timer_length

	var/mode = SHUTTLE_IDLE			//current shuttle mode
	var/callTime = 100				//time spent in transit (deciseconds). Should not be lower then 10 seconds without editing the animation of the hyperspace ripples.
	var/ignitionTime = 55			// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.
	var/rechargeTime = 0			//time spent after arrival before being able to launch again
	var/prearrivalTime = 0			//delay after call time finishes for sound effects, explosions, etc.

	var/landing_sound = 'sound/effects/controllable_shuttle/engine_landing.ogg'
	var/ignition_sound = 'sound/effects/controllable_shuttle/engine_startup.ogg'

	// The direction the shuttle prefers to travel in
	var/preferred_direction = NORTH
	// And the angle from the front of the shuttle to the port
	var/port_direction = NORTH

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/obj/docking_port/stationary/transit/assigned_transit


	var/list/movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)

	var/list/ripples = list()
	var/use_ripples = TRUE
	var/engine_coeff = 1 //current engine coeff
	var/current_engines = 0 //current engine power
	var/initial_engines = 0 //initial engine power
	var/can_move_docking_ports = FALSE //if this shuttle can move docking ports other than the one it is docked at
	var/list/hidden_turfs = list()

	var/crashing = FALSE

	var/shuttle_flags = NONE
	///All shuttle_control computers that share at least one control flag is able to link to this shuttle
	var/control_flags = NONE

	///Reference of the shuttle docker holding the mobile docking port
	var/obj/machinery/computer/camera_advanced/shuttle_docker/shuttle_computer

