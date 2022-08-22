/obj/machinery/computer/shuttle_control
	name = "general shuttle control console"
	desc = "Used to control spacecraft that are designed to move between local sectors in open space."
	/// The current flying state of the shuttle
	var/fly_state = SHUTTLE_DOCKED
	/// The next flying state of the shuttle
	var/next_fly_state = SHUTTLE_DOCKED
	/// The flying state we will have when reaching our destination
	var/destination_fly_state = SHUTTLE_DOCKED
	/// If the next destination is a transit
	var/to_transit = TRUE


/obj/machinery/computer/shuttle_control/attack_hand(mob/user)
	user.set_machine(src)
	tgui_interact(user)

/obj/machinery/computer/shuttle_control/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Shuttle", name)
		ui.open()

/obj/machinery/computer/shuttle_control/proc/shuttle_arrived()
	// if(fly_state == next_fly_state)
	// 	return
	// fly_state = next_fly_state
	// if(fly_state == SHUTTLE_IN_SPACE)
	// 	shuttle_port.assigned_transit.reserved_area.set_turf_type(/turf/open/space/transit)
	// if(to_transit)
	// 	to_transit = FALSE
	// 	next_fly_state = destination_fly_state
	// 	return
	// //give_actions()
	// if(fly_state == SHUTTLE_ON_GROUND)
	// 	TIMER_COOLDOWN_START(src, COOLDOWN_TADPOLE_LAUNCHING, launching_delay)
	// if(fly_state != SHUTTLE_IN_ATMOSPHERE)
	// 	return
	// shuttle_port.assigned_transit.reserved_area.set_turf_type(/turf/open/space/transit/atmos)
	// open_prompt = TRUE
	// if(ui_user?.Adjacent(src))
	// 	open_prompt(ui_user, GLOB.minidropship_start_loc)
