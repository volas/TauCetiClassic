/obj/machinery/computer/drone_control
	name = "Maintenance Drone Control"
	desc = "Used to monitor the station's drone population and the assembler that services them."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	light_color = "#b88b2e"
	req_access = list(access_engine_equip)
	circuit = "/obj/item/weapon/circuitboard/drone_control"

	//Used when pinging drones.
	var/drone_call_area = "Engineering"
	//Used to enable or disable drone fabrication.
	var/obj/machinery/drone_fabricator/dronefab

/obj/machinery/computer/drone_control/interact(user)
	if(istype(user, /mob/living/silicon/robot/drone))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
	else
		..()

/obj/machinery/computer/drone_control/ui_interact(mob/user)
	var/dat
	dat += "<B>Maintenance Units</B><BR>"

	for(var/mob/living/silicon/robot/drone/D in drone_list)
		dat += "<BR>[D.real_name] ([D.stat == DEAD ? "<font color='red'>INACTIVE</font>" : "<font color='green'>ACTIVE</font>"])"
		dat += "<font dize = 9><BR>Cell charge: [D.cell.charge]/[D.cell.maxcharge]."
		dat += "<BR>Currently located in: [get_area(D)]."
		dat += "<BR><A href='?src=\ref[src];resync=\ref[D]'>Resync</A> | <A href='?src=\ref[src];shutdown=\ref[D]'>Shutdown</A></font>"

	dat += "<BR><BR><B>Request drone presence in area:</B> <A href='?src=\ref[src];setarea=1'>[drone_call_area]</A> (<A href='?src=\ref[src];ping=1'>Send ping</A>)"

	dat += "<BR><BR><B>Drone fabricator</B>: "
	dat += "[dronefab ? "<A href='?src=\ref[src];toggle_fab=1'>[(dronefab.produce_drones && !(dronefab.stat & NOPOWER)) ? "ACTIVE" : "INACTIVE"]</A>" : "<font color='red'><b>FABRICATOR NOT DETECTED.</b></font> (<A href='?src=\ref[src];search_fab=1'>search</a>)"]"
	user << browse(entity_ja(dat), "window=computer;size=400x500")
	onclose(user, "computer")


/obj/machinery/computer/drone_control/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!allowed(usr))
		to_chat(usr, "\red Access denied.")
		return FALSE

	if (href_list["setarea"])

		//Probably should consider using another list, but this one will do.
		var/t_area = input("Select the area to ping.", "Set Target Area", null) as null|anything in tagger_locations

		if(!t_area)
			return FALSE

		drone_call_area = t_area
		to_chat(usr, "\blue You set the area selector to [drone_call_area].")

	else if (href_list["ping"])

		to_chat(usr, "\blue You issue a maintenance request for all active drones, highlighting [drone_call_area].")
		for(var/mob/living/silicon/robot/drone/D in drone_list)
			if(D.client && D.stat == CONSCIOUS)
				to_chat(D, "-- Maintenance drone presence requested in: [drone_call_area].")

	else if (href_list["resync"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["resync"])

		if(D.stat != DEAD)
			to_chat(usr, "\red You issue a law synchronization directive for the drone.")
			D.law_resync()

	else if (href_list["shutdown"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["shutdown"])

		if(D.stat != DEAD)
			to_chat(usr, "\red You issue a kill command for the unfortunate drone.")
			message_admins("[key_name_admin(usr)] issued kill order for drone [key_name_admin(D)] from control console.")
			log_game("[key_name(usr)] issued kill order for [key_name(src)] from control console.")
			D.shut_down()

	else if (href_list["search_fab"])
		if(dronefab)
			return

		for(var/obj/machinery/drone_fabricator/fab in oview(3,src))

			if(fab.stat & NOPOWER)
				continue

			dronefab = fab
			to_chat(usr, "\blue Drone fabricator located.")
			return

		to_chat(usr, "\red Unable to locate drone fabricator.")

	else if (href_list["toggle_fab"])

		if(!dronefab)
			return FALSE

		if(get_dist(src,dronefab) > 3)
			dronefab = null
			to_chat(usr, "\red Unable to locate drone fabricator.")
			return

		dronefab.produce_drones = !dronefab.produce_drones
		to_chat(usr, "\blue You [dronefab.produce_drones ? "enable" : "disable"] drone production in the nearby fabricator.")

	src.updateUsrDialog()
