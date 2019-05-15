/mob/living/carbon/alien/larva/emote(act,m_type=1,message = null)

	if(stat == UNCONSCIOUS || sleeping > 0)
		return
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		act = copytext(act, 1, t1)

	if(findtext(act, "s", -1) && !findtext(act, "_", -2))//Removes ending s's unless they are prefixed with a '_'
		if(act != "hiss")
			act = copytext(act, 1, length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)
		if("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'> You cannot send IC messages (muted).</span>")
					return
				if (src.client.handle_spam_prevention(message, MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if("custom")
			return custom_emote(m_type, message)
		if("scratch")
			if (!src.restrained())
				message = "<B>The [src.name]</B> scratches."
				m_type = 1
		if("whimper")
			if (!muzzled)
				if(last_sound_emote < world.time)
					playsound(src, 'sound/voice/xenomorph/small_roar.ogg', 100, TRUE)
					message = "<B>The [src.name]</B> whimpers sadly."
					m_type = 2
					last_sound_emote = world.time + 4 SECONDS
				else
					to_chat(src, "<span class='warning'>You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>The [src.name]</B> makes a weak noise."
				m_type = 2
		if("roar")
			if (!muzzled)
				if(last_sound_emote < world.time)
					playsound(src, 'sound/voice/xenomorph/small_roar.ogg', 100, TRUE)
					message = "<B>The [src.name]</B> roars [pick("softly", "like a little predator")]."
					m_type = 2
					last_sound_emote = world.time + 4 SECONDS
				else
					to_chat(src, "<span class='warning'>You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>The [src.name]</B> makes a noise."
				m_type = 2
		if("tail")
			message = "<B>The [src.name]</B> waves its tail[pick(" like a snake", "")]."
			m_type = 1
		if("drool")
			message = "<B>The [src.name]</B> drools [pick("like a little predator", "hungry")]."
			m_type = 1
		if("nod")
			message = "<B>The [src.name]</B> nods its head."
			m_type = 1
		if("sit")
			message = "<B>The [src.name]</B> sits down [pick("and curls up in a ball", "like a little kitten")]."
			m_type = 1
		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = 1
		if("sulk")
			message = "<B>The [src.name]</B> sulks down sadly."
			m_type = 1
		if("twitch")
			message = "<B>The [src.name]</B> twitches violently."
			m_type = 1
		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> dances around [pick("happily", "joyfully")]."
				m_type = 1
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> rolls [pick("like a snake", "on the floor", "around itslef")]."
				m_type = 1
		if("shake")
			message = "<B>The [src.name]</B> shakes its head."
			m_type = 1
		if("gnarl")
			if(!muzzled)
				message = "<B>The [src.name]</B> gnarls and shows its teeth."
				m_type = 1
		if("jump")
			message = "<B>The [src.name]</B> jumps around[pick(" happily", " joyfully", "")]."
			m_type = 1
		if("hiss")
			if(!muzzled)
				if(last_sound_emote < world.time)
					playsound(src, 'sound/voice/xenomorph/small_roar.ogg', 100, TRUE)
					message = "<B>The [src.name]</B> hisses softly."
					m_type = 2
					last_sound_emote = world.time + 4 SECONDS
				else
					to_chat(src, "<span class='warning'>You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>The [src.name]</B> makes a weak noise."
				m_type = 2
		if("growl")
			if(!muzzled)
				if(last_sound_emote < world.time)
					playsound(src, 'sound/voice/xenomorph/small_roar.ogg', 100, TRUE)
					message = "<B>The [src.name]</B> growls softly."
					m_type = 2
				else
					to_chat(src, "<span class='warning'>You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>The [src.name]</B> makes a weak noise."
		if("help")
			to_chat(src, "<span class ='notice'>SOUNDED IN <B>BOLD</B>:   dance, drool, grin, jump, <B>hiss</B>, nod, \
			                                                              <B>roar</B>, roll, scratch, shake, sit, sway, tail, twitch, <B>whimper</B>, <B>growl</B></span>")
		else
			to_chat(src, "<span class='notice'>This action is not provided: \"[act]\". Write \"*help\" to find out all available emotes. Write \"*me\" or \"*custom\" to do your own emote. \
			                                   Otherwise, you can perform your action via the \"F4\" button.</span>")
	if(message)
		log_emote("[name]/[key] : [message]")
		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if(m_type & 2)
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
