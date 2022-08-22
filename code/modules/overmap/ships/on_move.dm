/*
All ShuttleMove procs go here
*/

/************************************Base procs************************************/

// Called on every turf in the shuttle region, returns a bitflag for allowed movements of that turf
// returns the new move_mode (based o3n the old)
/turf/proc/fromShuttleMove(turf/newT, move_mode)
	if(!(move_mode & MOVE_AREA) || !isshuttleturf(src))
		return move_mode

	return move_mode | MOVE_TURF | MOVE_CONTENTS

// Called from the new turf before anything has been moved
// Only gets called if fromShuttleMove returns true first
// returns the new move_mode (based on the old)
/turf/proc/toShuttleMove(turf/oldT, move_mode, obj/docking_port/mobile/shuttle)
	. = move_mode
	if(!(. & (MOVE_TURF|MOVE_CONTENTS)))
		return

//	var/shuttle_dir = shuttle.dir
	for(var/atom/thing as anything in contents)
		if(ismob(thing))
			if(isliving(thing))
				var/mob/living/M = thing
				if(M.buckled)
					M.buckled.unbuckle_mob(M, TRUE)
				if(M.pulledby)
					M.pulledby.stop_pulling()
				M.stop_pulling()
				M.visible_message("<span class='warning'>[shuttle] slams into [M]!</span>")
				M.gib()
			continue
		// if(ismovable(thing))
		// 	var/atom/movable/movable_thing = thing
		// 	if(movable_thing.flags & SHUTTLE_IMMUNE)
		// 		movable_thing.forceMove(src)
		// 		movable_thing.invisibility = INVISIBILITY_ABSTRACT
		// 		continue
		// 	qdel(thing)

// Called on the old turf to move the turf data
/turf/proc/onShuttleMove(turf/newT, list/movement_force, move_dir)
	if(newT == src) // In case of in place shuttle rotation shenanigans.
		return
	//Destination turf changes
	//Baseturfs is definitely a list or this proc wouldnt be called
	var/shuttle_boundary = baseturfs.Find(/turf/baseturf_skipover/shuttle)
	if(!shuttle_boundary)
		CRASH("A turf queued to move via shuttle somehow had no skipover in baseturfs. [src]([type]):[loc]")
	var/depth = baseturfs.len - shuttle_boundary + 1
	newT.CopyOnTop(src, 1, depth, TRUE)

	return TRUE

// Called on the new turf after everything has been moved
/turf/proc/afterShuttleMove(turf/oldT, rotation)
	//Dealing with the turf we left behind
	oldT.TransferComponents(src)
	// SSexplosions.wipe_turf(src) // TODO:DUSHESS FIND ANALOGUE

	var/shuttle_boundary = baseturfs.Find(/turf/baseturf_skipover/shuttle)
	if(shuttle_boundary)
		oldT.ScrapeAway(baseturfs.len - shuttle_boundary + 1)

	if(rotation)
		shuttleRotate(rotation) //see shuttle_rotate.dm

	return TRUE

/turf/proc/lateShuttleMove(turf/oldT)


/mob/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(client && movement_force)
		var/shake_force = max(movement_force["THROW"], movement_force["KNOCKDOWN"])
		if(buckled)
			shake_force *= 0.25
		shake_camera(src, shake_force, 1)


// Called on atoms after everything has been moved
/atom/movable/proc/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)

	var/turf/newT = get_turf(src)
	if (newT.z != oldT.z)
		onTransitZ(oldT.z, newT.z)

	if(light)
		update_light()
	if(rotation)
		shuttleRotate(rotation)

	update_parallax_contents()

	return TRUE


// Called on every atom in shuttle turf contents before anything has been moved
// returns the new move_mode (based on the old)
// WARNING: Do not leave turf contents in beforeShuttleMove or dock() will runtime
/atom/movable/proc/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	return move_mode

// Called on atoms to move the atom to the new location
/atom/movable/proc/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return

	if(loc != oldT) // This is for multi tile objects
		return

	abstract_move(newT)

	return TRUE

/atom/movable/proc/lateShuttleMove(turf/oldT, list/movement_force, move_dir)
	if(!movement_force || anchored)
		return
	var/throw_force = movement_force["THROW"]
	if(!throw_force)
		return
	var/turf/target = get_edge_target_turf(src, move_dir)
	var/range = throw_force * 10
	range = CEILING(rand(range-(range*0.1), range+(range*0.1)), 10)/10
	var/speed = range/5
	safe_throw_at(target, range, speed) //, force = MOVE_FORCE_EXTREMELY_STRONG)

// Called on areas to move their turf between areas
/area/proc/onShuttleMove(turf/oldT, turf/newT, area/underlying_old_area)
	if(newT == oldT) // In case of in place shuttle rotation shenanigans.
		return TRUE

	contents -= oldT
	underlying_old_area.contents += oldT
	oldT.change_area(src, underlying_old_area) //lighting
	//The old turf has now been given back to the area that turf originaly belonged to

	var/area/old_dest_area = newT.loc
	parallax_movedir = old_dest_area.parallax_movedir

	old_dest_area.contents -= newT
	contents += newT
	newT.change_area(old_dest_area, src) //lighting
	return TRUE

// Called on areas after everything has been moved
/area/proc/afterShuttleMove(new_parallax_dir)
	parallax_movedir = new_parallax_dir
	return TRUE

/area/proc/lateShuttleMove()
	return

// Called on areas before anything has been moved
// returns the new move_mode (based on the old)
/area/proc/beforeShuttleMove(list/shuttle_areas)
	if(!shuttle_areas[src])
		return NONE
	return MOVE_AREA


/atom/movable/proc/onTransitZ(old_z,new_z)
	// SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_z, new_z)
	for(var/item in src) // Notify contents of Z-transition. This can be overridden IF we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)

/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE)
	return throw_at(target, range, speed, thrower, spin)

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY, copy_air = FALSE)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			// with default inputs this would be Copy(clamp(2, -INFINITY, baseturfs.len))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(clamp(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	var/turf/newT = copytarget.copyTurf(src, copy_air)
	newT.baseturfs = new_baseturfs


/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	// if(color)
	// 	T.atom_colours = atom_colours.Copy()
	// 	T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	return T