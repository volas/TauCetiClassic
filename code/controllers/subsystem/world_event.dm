SUBSYSTEM_DEF(world_event)
	name = "World Event"
	init_order = SS_INIT_WORLD_EVENT
	flags = SS_NO_FIRE // this controller is good place to process global events, if we need it one day

	var/datum/world_event/world_event
	var/custom_event_msg

/datum/controller/subsystem/world_event/Initialize()
	if(world_event)
		world_event.setup()
		log_admin("Global Event Module \"[world_event.name]\" loaded.")
		message_admins("Global Event Module \"[world_event.name]\" loaded.")

	return ..()

/datum/controller/subsystem/world_event/proc/setup_event(event_name)
	if(world_event)
		CRASH("Can't setup second global event \"[event_name]\", event \"[world_event.name]\" already loaded!")

	for(var/datum/world_event/GE in subtypesof(/datum/world_event))
		if(initial(GE).name == event_name)
			world_event = new GE
			break

	if(!world_event)
		CRASH("Can't setup global event \"[event_name]\"!")
