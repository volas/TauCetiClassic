/datum/map_module/forts
	name = "Forts Arena"

	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE

/datum/map_module/forts/New()
	..()

	// spawners
	create_spawner(/datum/spawner/fort_team/red)
	create_spawner(/datum/spawner/fort_team/blue)
