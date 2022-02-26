
// Called when the item is in the active hand, and clicked; alternately, there is an 'Click On Held Object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return

	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(user)

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/atom/movable/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(.) // Clickplace, no need for attack animation.
		return FALSE

	if(user.a_intent != INTENT_HARM)
		return FALSE

	var/had_effect = FALSE
	if(!(W.flags & NOATTACKANIMATION))
		user.do_attack_animation(src)
		had_effect = TRUE

	if(!(W.flags & NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")
		had_effect = TRUE

	if(!had_effect)
		return FALSE

	user.SetNextMove(CLICK_CD_MELEE)
	add_fingerprint(user)

	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(W)
	SSdemo.mark_dirty(user)

	return TRUE

/mob/living/attackby(obj/item/I, mob/user, params)
	user.SetNextMove(CLICK_CD_MELEE)

	if(ishuman(user))	//When abductor will hit someone from stelth he will reveal himself
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_INTERACT_ARMED, src)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(src, REACTION_ATACKED, user)

	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(I)
	SSdemo.mark_dirty(user)
	return I.attack(src, user, user.get_targetzone())

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity, params)
	return


/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user, def_zone) & COMPONENT_ITEM_NO_ATTACK)
		return

	var/mob/messagesource = M
	if (can_operate(M))        //Checks if mob is lying down on table for surgery
		if (do_surgery(M, user, src))
			return FALSE

	if(stab_eyes && user.a_intent != INTENT_HELP && (def_zone == O_EYES || def_zone == BP_HEAD))
		if((CLUMSY in user.mutations) && prob(50))
			M = user
		return eyestab(M,user)

	// Knifing
	if(edge)
		for(var/obj/item/weapon/grab/G in M.grabbed_by)
			if(G.assailant == user && G.state >= GRAB_NECK && def_zone == BP_HEAD)
				var/protected = 0
				if(ishuman(M))
					var/mob/living/carbon/human/AH = M
					if(AH.is_in_space_suit())
						protected = 1
				if(!protected)
					//TODO: better alternative for applying damage multiple times? Nice knifing sound?
					var/damage_flags = damage_flags()
					M.apply_damage(force, BRUTE, BP_HEAD, null, damage_flags)
					M.apply_damage(force, BRUTE, BP_HEAD, null, damage_flags)
					M.apply_damage(force, BRUTE, BP_HEAD, null, damage_flags)
					M.adjustOxyLoss(60) // Brain lacks oxygen immediately, pass out
					playsound(M, 'sound/effects/throat_cutting.ogg', VOL_EFFECTS_MASTER)
					flick(G.hud.icon_state, G.hud)
					user.SetNextMove(CLICK_CD_ACTION)
					user.visible_message("<span class='danger'>[user] slit [M]'s throat open with \the [name]!</span>")
					M.log_combat(user, "knifed with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
					return

	if (isbrain(M))
		messagesource = M:container
	if (length(hitsound))
		playsound(M, pick(hitsound), VOL_EFFECTS_MASTER)
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user
	user.do_attack_animation(M)

	if(slot_flags & SLOT_FLAGS_HEAD && def_zone == BP_HEAD && mob_can_equip(M, SLOT_HEAD, TRUE) && user.a_intent != INTENT_HARM)
		user.visible_message("<span class='danger'>[user] tries to put [name] on the [M]'s head!</span>")
		if(user.is_busy(src) || !do_after(user, 0.8 SECONDS, target = M))
			return
		user.remove_from_mob(src)
		M.equip_to_slot_if_possible(src, SLOT_HEAD, disable_warning = TRUE)
		user.visible_message("<span class='danger'>[user] slams [name] on the [M]'s head!</span>")
		M.log_combat(user, "slammed with [name] on the head (INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(BRUTE)])")
		var/list/data = user.get_unarmed_attack()
		// if item has no force just assume attacker smashed his fist (no scratches or any modifiers) against victim's head.
		if(user.a_intent in list(INTENT_PUSH, INTENT_GRAB))
			M.apply_damage(force + data["damage"], BRUTE, BP_HEAD)
			playsound(M, data["sound"], VOL_EFFECTS_MASTER)
		return TRUE

	M.log_combat(user, "attacked with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")

	var/power = force
	if(ishuman(user) && damtype == BRUTE)
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/BP = H.get_bodypart(H.hand ? BP_L_ARM : BP_R_ARM)
		if(BP.pumped)
			power += max(round((PARABOLIC_SCALING(force, 1, 0.01) * BP.pumped * 0.1)), 0) //We need a pumped force multiplied by parabolic scaled item's force with a borders of 1 to 0
	if(HULK in user.mutations)
		power *= 2

	if(!ishuman(M))
		if(isslime(M))
			var/mob/living/carbon/slime/slime = M
			if(prob(25))
				to_chat(user, "<span class='warning'>[src] passes right through [M]!</span>")
				return

			if(power > 0)
				slime.attacked += 10

			if(slime.Discipline && prob(50))	// wow, buddy, why am I getting attacked??
				slime.Discipline = 0

			if(power >= 3)
				if(isslimeadult(slime))
					if(prob(5 + round(power/2)))

						if(slime.Victim)
							if(prob(80) && !slime.client)
								slime.Discipline++
						slime.Victim = null
						slime.anchored = FALSE

						spawn()
							if(slime)
								slime.SStun = 1
								sleep(rand(5,20))
								if(slime)
									slime.SStun = 0

						spawn(0)
							if(slime)
								slime.canmove = 0
								step_away(slime, user)
								if(prob(25 + power))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1

				else
					if(prob(10 + power*2))
						if(slime)
							if(slime.Victim)
								if(prob(80) && !slime.client)
									slime.Discipline++

									if(slime.Discipline == 1)
										slime.attacked = 0

								spawn()
									if(slime)
										slime.SStun = 1
										sleep(rand(5,20))
										if(slime)
											slime.SStun = 0

							slime.Victim = null
							slime.anchored = FALSE


						spawn(0)
							if(slime && user)
								step_away(slime, user)
								slime.canmove = 0
								if(prob(25 + power*4))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1


		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		var/list/alt_alpperances_vieawers
		if(alternate_appearances)
			for(var/key in alternate_appearances)
				var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[key]
				if(!AA.alternate_obj || !istype(AA.alternate_obj, /obj))
					continue
				var/obj/alternate_obj = AA.alternate_obj
				alt_alpperances_vieawers = list()
				for(var/mob/alt_viewer in viewers(M))
					if(!alt_viewer.client || !(alt_viewer in AA.hudusers))
						continue
					alt_alpperances_vieawers += alt_viewer
					alt_viewer.show_message("<span class='warning'><B>[M] has been attacked with [alternate_obj.name][showname] </B></span>", SHOWMSG_VISUAL)

		if(attack_verb.len)
			messagesource.visible_message("<span class='warning'><B>[M] has been [pick(attack_verb)] with [src][showname] </B></span>", ignored_mobs = alt_alpperances_vieawers)
		else
			messagesource.visible_message("<span class='warning'><B>[M] has been attacked with [src][showname] </B></span>", ignored_mobs = alt_alpperances_vieawers)

		if(!showname && user)
			if(user.client)
				to_chat(user, "<span class='warning'><B>You attack [M] with [src]. </B></span>")

	// Attacking yourself can't miss
	if(user == M)
		def_zone = user.get_targetzone()
	else
		def_zone = def_zone? check_zone(def_zone) : get_zone_with_miss_chance(user.get_targetzone(), M)

	if(!def_zone)
		visible_message("<span class='userdanger'>[user] misses [M] with \the [src]!</span>")
		return FALSE

	if(user != M)
		user.do_attack_animation(M)
		if(M.check_shields(src, force, "the [name]", get_dir(user, M) ))
			return FALSE

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		return H.attacked_by(src, user, def_zone)	//make sure to return whether we have hit or miss
	else
		switch(damtype)
			if("brute")
				if(isslime(src))
					M.adjustBrainLoss(power)

				else
					if(prob(33)) // Added blood for whacking non-humans too
						var/turf/simulated/T = M.loc
						if(istype(T))
							T.add_blood_floor(M)
					M.take_bodypart_damage(power)
			if("fire")
				if (!(COLD_RESISTANCE in M.mutations))
					to_chat(M, "Aargh it burns!")
					M.take_bodypart_damage(0, power)

	add_fingerprint(user)
	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(M)
	SSdemo.mark_dirty(user)
	return TRUE
