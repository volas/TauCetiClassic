///Level below the floor, for undertile component
/atom/movable/screen/plane_master/underfloor
	name = "underfloor plane master"
	plane = UNDERFLOOR_PLANE
	blend_mode = BLEND_OVERLAY

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	blend_mode = BLEND_OVERLAY

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world/apply_effects(client/client, map_view)
	if(!..())
		return

	if(client.prefs?.ambientocclusion)
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/game_world_above
	name = "above game world plane master"
	plane = ABOVE_GAME_PLANE
	render_relay_plane = list(GAME_PLANE)
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/seethrough
	name = "seethrough plane master"
	plane = SEETHROUGH_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/ghost
	name = "ghost plane master"
	plane = GHOST_PLANE
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/ghost_illusion
	name = "ghost illusion plane master"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GHOST_ILLUSION_PLANE

/atom/movable/screen/plane_master/ghost_illusion/apply_effects(client/client, map_view)
	if(!..())
		return

	add_filter("ghost_illusion", 1, motion_blur_filter(x = 3, y = 3))

/atom/movable/screen/plane_master/point
	name = "point plane master"
	plane = POINT_PLANE
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/area
	name = "area plane"
	plane = AREA_PLANE

/atom/movable/screen/plane_master/fullscreen
	name = "fullscreen alert plane"
	plane = FULLSCREEN_PLANE
	render_relay_plane = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/singularity
	name = "singularity plane"
	plane = SINGULARITY_PLANE
	render_relay_plane = list(RENDER_PLANE_ABOVE_GAME)

/atom/movable/screen/plane_master/camera_static
	name = "camera static plane master"
	plane = CAMERA_STATIC_PLANE
	blend_mode = BLEND_OVERLAY
