/obj/effect/overmap
	name = "map object"
	icon = 'icons/obj/ships/overmap.dmi'
	icon_state = "object"
	color = "#fffffe"

	var/known = TRUE		//shows up on nav computers automatically
	var/scannable       //if set to TRUE will show up on ship sensors for detailed scans

//Overlay of how this object should look on other skyboxes
/obj/effect/overmap/proc/get_skybox_representation()
	return

/obj/effect/overmap/proc/get_scan_data(mob/user)
	return desc

/obj/effect/overmap/Initialize()
	. = ..()
	if(!GLOB.using_map.use_overmap)
		return INITIALIZE_HINT_QDEL

	if(known)
		layer = ABOVE_LIGHTING_LAYER
		plane = ABOVE_LIGHTING_PLANE

	update_icon()

/obj/effect/overmap/Crossed(var/obj/effect/overmap/visitable/other)
	return

/obj/effect/overmap/Uncrossed(var/obj/effect/overmap/visitable/other)
	return

/**
 * Flags the effect as `known` and runs relevant update procs. Intended for admin event usage.
 */
/obj/effect/overmap/proc/make_known(notify = FALSE)
	if (!known)
		known = TRUE
		update_known_connections(notify)


/**
 * Runs any relevant code needed for updating anything connected to known overmap effects, such as helms.
 */
/obj/effect/overmap/proc/update_known_connections(notify = FALSE)
	return