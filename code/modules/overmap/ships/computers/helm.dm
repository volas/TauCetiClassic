/obj/machinery/computer/ship/helm
	name = "helm control console"
	icon_state = "holocontrol"
	light_color = "#7faaff"
	desc = "A navigation system used to control spacecraft big and small, allowing for configuration of heading and autopilot as well as providing navigational data."
	var/autopilot = 0
	var/list/known_sectors = list()
	var/dx		//desitnation
	var/dy		//coordinates
	var/speedlimit = 1/(20 SECONDS) //top speed for autopilot, 5
	var/accellimit = 0.001 //manual limiter for acceleration
	/// The mob currently operating the helm - The last one to click one of the movement buttons and be on the overmap screen. Set to `null` for autopilot or when the mob isn't in range.
	var/mob/current_operator