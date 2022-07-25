// todo more admin_log

var/global/list/admin_events_types

/client/proc/load_admin_event()
	set name = "Load Event Module"
	set category = "Event"

	var/event_select = tgui_input_list(src, "Select event from the list", "Admin Event Setup", admin_events_types | "Abort")
	
	if(!type || type == "Abort")
		return
	
	var/datum/admin_event/event = new admin_events_types[event_select]

	if(!event.setup(usr))
		return

	LAZYADD(SSticker.admin_events, event)

// simple wrapper to help build in admin events
/datum/admin_event
	var/name = "Admin event wrapper"

	var/list/mapload_maps // list(list(mappath, list(traits)), ...)

	var/list/player_verbs
	var/list/admin_verbs // list(list(path = path, flag = flag), ...)

	var/default_event_message

	var/list/dresser_outfits // list of /datum/outfit/event

	var/suppress_stat = TRUE // should we drop stat.json or no

	// set TRUE to toggle off corresponding configs
	var/cf_disable_enter_allowed = FALSE // set TRUE to toggle off config.enter_allowed
	var/cf_disable_allow_random_events = TRUE // set TRUE to toggle off config.allow_random_events

	var/event_message
	var/announce_chat_bridge = FALSE

/datum/admin_event/proc/admin_config(client/user)
	// reload to add more 

	if(tgui_alert(user, "You want to start \"[name]\", are you sure?", "Admin Event Setup", list("Yes","No")) == "No")
		return FALSE
	
	var/event_message = sanitize(input(usr, "Enter or edit event message. You can edit it later with \"Change Custom Event\" command.", "Admin Event Setup", input_default(default_event_message)) as message|null, MAX_BOOK_MESSAGE_LEN, extra = FALSE)
	
	if(event_message)
		announce_chat_bridge = tgui_alert(user,"Do you want to announce event in discord?","Admin Event Setup", list("Yes","No")) == "Yes"

	return TRUE

/datum/admin_event/proc/setup(client/user)
	if(!admin_config(user))
		message_admins("AdminEvent: \"[name]\": config error, aborted.")
		return

	if(mapload_maps)
		for(var/map in mapload_maps)
			maploader.load_new_z_level(map["mappath"], map["traits"])
		message_admins("AdminEvent: \"[name]\": maps loaded.")

	if(cf_disable_enter_allowed)
		config.enter_allowed = FALSE
		message_admins("AdminEvent: \"[name]\": disabled new player entering.")

	if(cf_disable_allow_random_events)
		config.allow_random_events = FALSE
		message_admins("AdminEvent: \"[name]\": disabled random events.")

	if(player_verbs)
		setup_player_verbs()
		message_admins("AdminEvent: \"[name]\": new player buttons added.")

	if(admin_verbs)
		setup_admin_verbs()
		load_admins() // reload admins with new verbs 
		message_admins("AdminEvent: \"[name]\": new admin buttons added.")

	if(event_message)
		SSticker.custom_event_msg = event_message
		to_chat(world, CUSTOM_EVENT_MESSAGE_FORMATTED)

	if(announce_chat_bridge)
		world.send2bridge(
			type = list(BRIDGE_ANNOUNCE),
			attachment_title = "Admin Event",
			attachment_msg = SSticker.custom_event_msg + "\nJoin now: <[BYOND_JOIN_LINK]>",
			attachment_color = BRIDGE_COLOR_ANNOUNCE,
			mention = BRIDGE_MENTION_EVENT,
		)

/datum/admin_event/proc/setup_admin_verbs()
	if(!admin_verbs)
		return
	
	// don't like it, need to rewrite admin verbs
	for(var/V in admin_verbs)
		if(V["flag"] & R_ADMIN)
			global.admin_verbs_admin += V["path"]
		else if(V["flag"] & R_FUN)
			global.admin_verbs_fun += V["path"]
		else if(V["flag"] & R_PERMISSIONS)
			global.admin_verbs_permissions += V["path"]
		else
			stack_trace("Unsupported admin flag for [V["path"]]")

/datum/admin_event/proc/setup_player_verbs()
	if(!player_verbs)
		return

	for(var/client/C in global.clients)
		C.verbs |= player_verbs

/datum/admin_event/process()
	return ..()
	
// hooks
/datum/admin_event/proc/event_start()
/datum/admin_event/proc/event_round_end()
