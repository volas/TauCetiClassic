//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33
var/global/list/rad_collectors = list()

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and phoron to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(access_engine_equip)
	use_power = 0
	var/obj/item/weapon/tank/phoron/P = null
	var/last_power = 0
	var/active = FALSE
	var/locked = FALSE
	var/drainratio = 1

/obj/machinery/power/rad_collector/atom_init()
	. = ..()
	rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	rad_collectors -= src
	return ..()

/obj/machinery/power/rad_collector/process()
	if(P)
		if(P.air_contents.gas["phoron"] == 0)
			investigate_log("<font color='red'>out of fuel</font>.","singulo")
			eject()
		else
			P.air_contents.adjust_gas("phoron", -0.001 * drainratio)
	return

/obj/machinery/power/rad_collector/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_RAPID)
	if(anchored)
		if(!locked || IsAdminGhost(user))
			toggle_power()
			user.visible_message(
				"[user.name] turns the [name] [active? "on":"off"].",
				"You turn the [name] [active? "on":"off"].")
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [P?"Fuel: [round(P.air_contents.gas["phoron"]/0.29)]%":"<font color='red'>It is empty</font>"].","singulo")
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return 1

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/analyzer))
		to_chat(user, "\blue The [W.name] detects that [last_power]W were recently produced.")
		return 1
	else if(istype(W, /obj/item/weapon/tank/phoron))
		if(!src.anchored)
			to_chat(user, "\red The [src] needs to be secured to the floor first.")
			return 1
		if(src.P)
			to_chat(user, "\red There's already a phoron tank loaded.")
			return 1
		user.drop_item()
		src.P = W
		W.loc = src
		update_icons()
	else if(istype(W, /obj/item/weapon/crowbar))
		if(P && !src.locked)
			eject()
			return 1
	else if(istype(W, /obj/item/weapon/wrench))
		if(P)
			to_chat(user, "\blue Remove the phoron tank first.")
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		src.anchored = !src.anchored
		user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
			"You [anchored? "secure":"undo"] the external bolts.", \
			"You hear a ratchet")
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "\red The controls can only be locked when the [src] is active")
		else
			to_chat(user, "\red Access denied!")
			return 1
	else
		..()
		return 1


/obj/machinery/power/rad_collector/ex_act(severity)
	switch(severity)
		if(2, 3)
			eject()
	return ..()


/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	var/obj/item/weapon/tank/phoron/Z = src.P
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	src.P = null
	if(active)
		toggle_power()
	else
		update_icons()

/obj/machinery/power/rad_collector/proc/receive_pulse(pulse_strength)
	if(P && active)
		var/power_produced = 0
		power_produced = P.air_contents.gas["phoron"] * pulse_strength * 20
		add_avail(power_produced)
		last_power = power_produced
		return
	return


/obj/machinery/power/rad_collector/proc/update_icons()
	overlays.Cut()
	if(P)
		overlays += image('icons/obj/singularity.dmi', "ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		overlays += image('icons/obj/singularity.dmi', "on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icons()
	return

