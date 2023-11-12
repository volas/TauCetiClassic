/datum/map_module
	var/name = "default"

	var/default_event_message
	var/default_event_name

	var/list/player_verbs
	var/list/admin_verbs

	var/config_disable_random_events = TRUE

/datum/map_module/proc/setup()
//	SHOULD_CALL_PARENT(TRUE)

	if(player_verbs)
		setup_additional_player_verbs(player_verbs, "Map")

	if(admin_verbs)
		setup_additional_admin_verbs(add_verbs, "Map")

	if(default_event_message || default_event_name)
		SSevents.setup_custom_event(default_event_message, default_event_name)
