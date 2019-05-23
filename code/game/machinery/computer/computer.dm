/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0

	var/light_range_on = 1.5
	var/light_power_on = 3
	var/last_keyboard_sound = 0 // prevents keyboard sounds spam

	var/state_broken_preset = null // used if we want to choose icon_state that is going to be used
	var/state_nopower_preset = null

/obj/machinery/computer/atom_init(mapload, obj/item/weapon/circuitboard/C)
	. = ..()
	computer_list += src
	if(C && istype(C))
		circuit = C
	else
		if(circuit)
			circuit = new circuit(null)
	power_change()

/obj/machinery/computer/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list && (last_keyboard_sound <= world.time))
		playsound(src, "keyboard", 50, FALSE, -4)
		last_keyboard_sound = world.time + 8

/obj/machinery/computer/Destroy()
	computer_list -= src
	return ..()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/meteorhit(obj/O)
	for(var/x in verbs)
		verbs -= x
	set_broken()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()
	return


/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		if(3.0)
			if (prob(25))
				for(var/x in verbs)
					verbs -= x
				set_broken()
		else
	return

/obj/machinery/computer/bullet_act(obj/item/projectile/Proj)
	if(prob(Proj.damage))
		set_broken()
	..()


/obj/machinery/computer/blob_act()
	if (prob(75))
		for(var/x in verbs)
			verbs -= x
		set_broken()
		density = 0

/obj/machinery/computer/update_icon()
	..()
	icon_state = initial(icon_state)
	// Broken
	if(stat & BROKEN)
		if(state_broken_preset)
			icon_state = state_broken_preset
		else
			icon_state = "[initial(icon_state)]b"
	// Powered
	else if(stat & NOPOWER)
		if(state_nopower_preset)
			icon_state = state_nopower_preset
		else
			icon_state = "[initial(icon_state)]0"

/obj/machinery/computer/power_change()
	..()
	update_icon()
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(light_range_on, light_power_on)
	return


/obj/machinery/computer/proc/set_broken()
	if(circuit) //no circuit, no breaking
		stat |= BROKEN
		update_icon()
	return

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = replacetext(text, "\n", "<BR>")
	return text

/obj/machinery/computer/attackby(obj/item/I, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>It's too complicated for you.</span>")
		return
	if(isscrewdriver(I) && circuit && !(flags&NODECONSTRUCT))
		if(user.is_busy(src)) return
		if(I.use_tool(src, user, 20, volume = 50))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			transfer_fingerprints_to(A)
			A.circuit = circuit
			A.anchored = 1
			A.dir = dir
			circuit = null
			for (var/obj/C in src)
				C.loc = src.loc
			if (src.stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				new /obj/item/weapon/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				set_light(0)
				A.state = 4
				A.icon_state = "4"
			qdel(src)
	if(iswrench(I))
		if(user.is_busy(src))
			return
		var/list/possible_directions = list()
		for(var/direction_to_check in cardinal)
			if(direction_to_check != dir)
				switch(direction_to_check)
					if(SOUTH)
						possible_directions += "south"
					if(WEST)
						possible_directions += "west"
					if(EAST)
						possible_directions += "east"
		var/dir_choise = input(user, "Choose the direction where to turn \the [src].", "Choose the direction.", null) as null|anything in possible_directions
		if(!dir_choise)
			return
		if(user.is_busy(src))
			return
		if(!user || !(user in range(1, src)))
			return
		if(I.use_tool(src, user, 20, volume = 50) && src && I)
			user.visible_message("<span class='notice'>[user] turns \the [src] [dir_choise].</span>","<span class='notice'>You turn \the [src] [dir_choise].</span>")
			switch(dir_choise)
				if("south")
					dir = SOUTH
				if("west")
					dir = WEST
				if("east")
					dir = EAST
		return

/obj/machinery/computer/verb/rotate()
	set category = "Object"
	set name = "Rotate"
	set src in oview(1)
	if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || issilicon(usr))
		return
	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>It's too complicated for you.</span>")
		return
	if(usr.is_busy(src))
		return
	var/obj/item/I = usr.get_active_hand()
	if(I && iswrench(I))
		var/list/possible_directions = list()
		for(var/direction_to_check in cardinal)
			if(direction_to_check != dir)
				switch(direction_to_check)
					if(SOUTH)
						possible_directions += "south"
					if(WEST)
						possible_directions += "west"
					if(EAST)
						possible_directions += "east"
		var/dir_choise = input(usr, "Choose the direction where to turn \the [src].", "Choose the direction.", null) as null|anything in possible_directions
		if(!dir_choise)
			return
		if(usr.is_busy(src))
			return
		if(!usr || !(usr in range(1, src)))
			return
		if(I.use_tool(src, usr, 20, volume = 50) && src && I)
			usr.visible_message("<span class='notice'>[usr] turns \the [src] [dir_choise].</span>","<span class='notice'>You turn \the [src] [dir_choise].</span>")
			switch(dir_choise)
				if("south")
					dir = SOUTH
				if("west")
					dir = WEST
				if("east")
					dir = EAST
	else
		to_chat(usr, "<span class='warning'>You need to hold a wrench in your active hand to do this.</span>")
	return

/obj/machinery/computer/attack_hand(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(HULK in H.mutations)
			if(stat & (BROKEN))
				return 1
			if(H.a_intent == "hurt")
				H.visible_message("<span class='danger'>[H.name] smashes [src] with \his mighty arms!</span>")
				set_broken()
				return 1
			else
				H.visible_message("<span class='danger'>[H.name] stares cluelessly at [src] and drools.</span>")
				return 1
	. = ..()

/obj/machinery/computer/attack_paw(mob/user)
	if(circuit)
		user.SetNextMove(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(prob(10))
			user.visible_message("<span class='danger'>[user.name] smashes the [src.name] with \his paws.</span>",
			"<span class='danger'>You smash the [src.name] with your paws.</span>",
			"<span class='danger'>You hear a smashing sound.</span>")
			set_broken()
			return
	user.visible_message("<span class='danger'>[user.name] smashes against the [src.name] with \his paws.</span>",
	"<span class='danger'>You smash against the [src.name] with your paws.</span>",
	"<span class='danger'>You hear a clicking sound.</span>")

/obj/machinery/computer/attack_alien(mob/user)
	if(istype(user, /mob/living/carbon/alien/humanoid/queen))
		attack_hand(user)
		return
	if(circuit)
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		if(prob(80))
			user.visible_message("<span class='danger'>[user.name] smashes the [src.name] with \his claws.</span>",
			"<span class='danger'>You smash the [src.name] with your claws.</span>",
			"<span class='danger'>You hear a smashing sound.</span>")
			set_broken()
			return
	user.visible_message("<span class='danger'>[user.name] smashes against the [src.name] with \his claws.</span>",
	"<span class='danger'>You smash against the [src.name] with your claws.</span>",
	"<span class='danger'>You hear a clicking sound.</span>")
