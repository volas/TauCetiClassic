/datum/spawner/fort_team
	name = "Fort Team"
	desc = "Отстраивайте и защищайте форт своей команды, уничтожьте форт команды противников"
	//wiki_ref = "Forst event" // todo

	lobby_spawner = TRUE
	// сделать зависимым от фракции...
	positions = INFINITY


/datum/spawner/fort_team/red
	name = "Red Team"
	spawn_landmark_name = "Red Team" // /obj/effect/landmark/red_team

/datum/spawner/fort_team/blue
	name = "Blue Team"
	spawn_landmark_name = "Blue Team" // /obj/effect/landmark/blue_team
