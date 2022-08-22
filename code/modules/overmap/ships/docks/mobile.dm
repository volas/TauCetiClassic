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
	var/obj/machinery/computer/shuttle_control/shuttle_computer

/obj/docking_port/mobile/register()
	. = ..()
	SSshuttle.mobile += src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		destination = null
		previous = null
		QDEL_NULL(assigned_transit)		//don't need it where we're goin'!
		shuttle_areas = null
		remove_ripples()
	return ..()

/obj/docking_port/mobile/proc/setTimer(wait)
	timer = world.time + wait
	last_timer_length = wait

/obj/docking_port/mobile/atom_init(mapload, ...)
	. = ..()

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	shuttle_areas = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/cur_area = get_area(curT)
		if(istype(cur_area, area_type))
			shuttle_areas[cur_area] = TRUE


	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	if(!check_dock(S))
		WARNING("check_dock failed on request for [src]")
		return

	if(mode == SHUTTLE_IGNITING && destination == S)
		return

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(timeLeft(1) < callTime * engine_coeff)
					setTimer(callTime * engine_coeff)
			else
				destination = S
				destination.reservedId = id
				setTimer(callTime * engine_coeff)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime * engine_coeff - timeLeft(1))
			else
				destination = S
				destination.reservedId = id
				setTimer(callTime * engine_coeff)
			set_mode(SHUTTLE_CALL)
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING, SHUTTLE_RECHARGING)
			destination = S
			destination.reservedId = id
			set_mode(SHUTTLE_IGNITING)
			on_ignition()
			setTimer(ignitionTime)
		else
			stack_trace("Called request() with mode: [mode].")

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT

	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK

	if(dwidth > S.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE

	if(width-dwidth > S.width-S.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE

	if(dheight > S.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE

	if(height-dheight > S.height-S.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE

	//check the dock isn't occupied
	var/currently_docked = S.get_docked()
	if(currently_docked)
		// by someone other than us
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
		// This isn't an error, per se, but we can't let the shuttle code
		// attempt to move us where we currently are, it will get weird.
			return SHUTTLE_ALREADY_DOCKED

	if(S?.reservedId != id) // Checks so two shuttles don't get the same dock and conflict.
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(S.reservedId)
		if(M?.destination == S)
			return SHUTTLE_RESERVED
		S.reservedId = null //Assigned shuttle does not exist or doesn't have the port as it's destination.

	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S, silent=FALSE)
	if(crashing)
		return TRUE
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else
		if((status != SHUTTLE_ALREADY_DOCKED && status != SHUTTLE_RESERVED) && !silent) // SHUTTLE_ALREADY_DOCKED is no cause for error
			var/msg = "Shuttle [src] cannot dock at [S], error: [status]"
			message_admins(msg)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return FALSE

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10

	var/ds_remaining
	if(!timer)
		ds_remaining = callTime * engine_coeff
	else
		ds_remaining = max(0, timer - world.time)

	. = round(ds_remaining / divisor, 1)

/obj/docking_port/mobile/proc/set_mode(new_mode)
	mode = new_mode
	SEND_SIGNAL(src, COMSIG_SHUTTLE_SETMODE, mode)

// called on entering the igniting state
/obj/docking_port/mobile/proc/on_ignition()
	playsound(return_center_turf(), ignition_sound, 60, 0)

/obj/docking_port/mobile/proc/remove_ripples()
	QDEL_LIST(ripples)

//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	return TRUE

/obj/docking_port/mobile/proc/cleanup_runway(obj/docking_port/stationary/new_dock, list/old_turfs, list/new_turfs, list/areas_to_move, list/moved_atoms, rotation, movement_direction, area/underlying_old_area)
	underlying_old_area.afterShuttleMove()
