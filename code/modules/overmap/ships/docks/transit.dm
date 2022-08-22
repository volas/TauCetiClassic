/obj/docking_port/stationary/transit
	name = "In Transit"
	var/datum/turf_reservation/reserved_area
	var/area/shuttle/transit/assigned_area
	var/obj/docking_port/mobile/owner

	var/spawn_time

/obj/docking_port/stationary/transit/atom_init(mapload, ...)
	. = ..()

	SSshuttle.transit += src
	spawn_time = world.time

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		if(get_docked())
			log_debug("A transit dock was destroyed while something was docked to it.")
		SSshuttle.transit -= src
		if(owner)
			if(owner.assigned_transit == src)
				log_debug("A transit dock was qdeled while it was assigned to [owner].")
				owner.assigned_transit = null
			owner = null
		if(!QDELETED(reserved_area))
			qdel(reserved_area)
		reserved_area = null
	return ..()
