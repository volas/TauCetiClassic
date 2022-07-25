/datum/admin_event/forts
	name = "Forts Arena"

	mapload_maps = list(list('maps/event/forts.dmm', list("Linkage" = "Self")))

	player_verbs = list()
	admin_verbs = list()

	default_event_message = ""

	dresser_outfits = list()// list of /datum/outfit/event // todo

	suppress_stat = TRUE

	// set TRUE to toggle off corresponding configs
	cf_disable_enter_allowed = FALSE // set TRUE to toggle off config.enter_allowed
	cf_disable_allow_random_events = TRUE // set TRUE to toggle off config.allow_random_events

/datum/admin_event/forts/admin_config()
	. = ..()

	if(!.)
		return FALSE

	return TRUE
	//подключить гейт?
	//да - дать выход с гейта на карту

	//включить спавнеры?
	//да - админу не нужно спавнить, игроки сами зайдут через спавнер (в спавнере проверять сколько человек в командах, если меньше/больше - не давать и просить другую команду)

	//сколько команд?
	//2 или 4

/datum/admin_event/forts/setup()
	return ..()

//Admin verb toggles
var/list/event_verbs = list(/client/proc/toggle_fields, /client/proc/spawn_bomb)
//1 - nothing, 2 - objects, 3 - all
/client/proc/toggle_fields()
	set category = "Event"
	set name = "Toggle Event Fields"

	var/msg
	if(event_field_stage==1)
		event_field_stage=2
		msg = "OBJECTS may pass"
	else if(event_field_stage==2)
		event_field_stage=3
		msg = "OBJECTS and MOBS may pass"
	else if(event_field_stage==3)
		event_field_stage=1
		msg = "NOTHING may pass"

	log_admin("[usr.key] has toggled event force field, now [msg].")
	message_admins("[key_name_admin(usr)] has toggled event force field, now [msg].")

	for(var/obj/effect/decal/teamchallenge/shield in team_shields)
		shield.update_icon()

/client/proc/spawn_bomb()
	set category = "Event"
	set name = "Spawn Bomb"

	log_admin("[usr.key] has spawned event bombs.")
	message_admins("[key_name_admin(usr)] has spawned event bombs.")

	for(var/obj/structure/bomb_telepad/T in bomb_spawners)
		if(T.anchored)
			T.do_spawn()
