/obj/docking_port/stationary/ 
	name = "Daedalus hangar pad"
	id = SHUTTLE_EXPLORATION
	roundstart_template = /datum/map_template/shuttle/daedalus

/datum/map_template/shuttle/daedalus
	shuttle_id = SHUTTLE_EXPLORATION
	name = "NSV 'Daedalus'"
	mappath = "maps/shuttles/daedalus.dmm"

/datum/map_template/shuttle/daedalus/New()
	. = ..()
	log_debug("adding shuttles")

/obj/docking_port/mobile/daedalus
	name = "Daedalus"
	id = SHUTTLE_EXPLORATION
	dwidth = 0
	dheight = 0
	width = 7
	height = 9
	rechargeTime = 0


