var/global/list/atom/movable/screen/all_plane_masters

/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR

	// because we use render relays, plane number is not so important anymore
	// but you need it to combine objects and plane masters
	plane = LOWEST_EVER_PLANE

	// blend mode to use when applying to the render relays (same as old blend_mode_override)
	blend_mode = BLEND_OVERLAY

	// what planes we will relay this plane render to
	// set to null if you don't want to render plane on anything (for example, if you want to use it for filters)
	// todo: make it associative list(PLANE = BLEND_MODE) if we ever need different blend_mode for relays
	var/list/render_relay_planes = list(RENDER_PLANE_GAME)

	var/render_target = "*" + type::name + ": AUTOGENERATED RENDER TGT"

/atom/movable/screen/plane_master/atom_init(client/client, map_view)
	if(src in client.screen)
		WARNING("render() called multiple times for [client] [src.type]!")
		return

	if(map_view)
		assigned_map = map_view
		screen_loc = "[map_view]:[screen_loc]"

	apply_effects(client, map_view)

	client.screen += src

	if(!isnull(render_relay_planes))
		for(var/relay_plane in render_relay_planes)
			// here I assume that plane always exists and we don't need to destroy it,
			// so there is no need to keep render_plane_relay references anywhere except for client.screen
			// and for outer maps we just cleanup it all at once based on assigned_map value
			client.screen += new /atom/movable/render_plane_relay(client, src, relay_plane)

	return ..()

// For filters and other effects
/atom/movable/screen/plane_master/proc/apply_effects(client/client, map_view)
	SHOULD_CALL_PARENT(TRUE)

	clear_filters()

	if(!client)
		return FALSE

	return TRUE

/*/atom/movable/screen/plane_master/proc/register_fullscreen(client/client, fullscreen)
	if(map)
		...
	else
		...*/

// client/update_plane_masters(/type/)
// for(var/type in client.screen)
//		istype() ? type.apply_effects()
