/mob/living/carbon/alien/humanoid/emote(act, m_type=1, message = null, player_caused)

	if(stat == DEAD && (act != "deathgasp"))
		return
	if(stat == UNCONSCIOUS || sleeping > 0)
		return
	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		if(act != "hiss")
			act = copytext(act,1,length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)
		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "\red You cannot send IC messages (muted).")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)
		if ("deathgasp")
			if(!muzzled)
				if(last_sound_emote < world.time)
					message = "<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw..."
					m_type = 1
					playsound(src, 'sound/voice/xenomorph/death_1.ogg', 40, 1)
					last_sound_emote = world.time + 15 SECONDS
					to_chat(src, "<span class='warning'>Pretending to be dead is not a good idea. I must fight for my Queen!</span>")
				else
					to_chat(src, "<span class='warning'>You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>[src]</B> breathlessly falls to the floor, opens their mouth and does not move. Looks like its dead."
				m_type = 1
		if("scratch")
			message = "<B>The [src.name]</B> [pick("maliciously", "menacingly", "excitedly", "erotically")] scratches the floor with its claws on its feet."
			m_type = 1
		if("whimper")
			if (!muzzled)
				if(last_sound_emote < world.time)
					message = pick("<B>The [src.name]</B> sadly screeches.", "<B>The [src.name]</B> sadly whines.")
					m_type = 2
					playsound(src, 'sound/voice/xenomorph/death_screech.ogg', 20, 1)
				else
					to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if("roar")
			if (!muzzled)
				if(last_sound_emote < world.time)
					message = "<B>The [src.name]</B>[pick(" triumphantly", " menacingly", "")] roars."
					m_type = 2
					playsound(src, "xenomorph_roar", 70, 0)
					last_sound_emote = world.time + 10 SECONDS
				else
					to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>[src]</B> makes a [pick("HEAVY", "STRONG", "LOUD")] noise."
				m_type = 2
		if("tail")
			message = "<B>The [src.name]</B>[pick("", " menacingly", " slyly", " deftly", " erotically")] waves its tail."
			m_type = 1
		if("twitch")
			message = "<B>The [src.name]</B> [pick("unbearably", "mockingly")] twitches."
			m_type = 1
		if("drool")
			message = "<B>The [src.name]</B> drools [pick("like a true predator", "hungry")]."
			m_type = 1
		if("happy_hiss")
			if(!muzzled)
				if(last_sound_emote < world.time)
					message = "<B>The [src.name]</B> [pick("cheerfully", "joyfully")] hisses!"
					m_type = 2
					playsound(src, "xenomorph_hiss", 60, 0)
					last_sound_emote = world.time + 6 SECONDS
				else
					to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if("hiss")
			if(!muzzled)
				if(last_sound_emote < world.time)
					message = "<B>The [src.name]</B>[pick(" predatory", " dissatisfied", " maliciously", " menacingly", " suspiciously", "")] hisses!"
					m_type = 2
					playsound(src, "xenomorph_hiss", 80, 0)
					last_sound_emote = world.time + 6 SECONDS
				else
					to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if("growl")
			if(!muzzled)
				if(last_sound_emote < world.time)
					message = "<B>The [src.name]</B>[pick(" relaxed", " predatory", " excitedly", " joyfully", " maliciously", " menacingly", " suspiciously", "")] growls."
					m_type = 2
					playsound(src, "xenomorph_growl", 80, 0)
					last_sound_emote = world.time + 7 SECONDS
				else
					to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
			else
				message = "<B>The [src.name]</B> looks around angrily, making a faint noise."
				m_type = 2
		if("nod")
			message = "<B>The [src.name]</B> [pick("slowly", "predatory")] nods its head."
			m_type = 1
		if("sit")
			message = "<B>The [src.name]</B> sits down[pick(" like a good girl", " wearily", " and turns his tail into a ball")]."
			m_type = 1
			if(prob(33)) // xenomorphs are not good boys!
				to_chat(src, "<span class='warning'>You feel shame. [pick("You want to hunt, not waste time", "You're not an obedient girl", "You're not a good girl")].</span>")
		if("sway")
			message = "<B>The [src.name]</B> sways around [pick("dizzily", "drunkenly", "wearily")]."
			m_type = 1
		if("sulk")
			message = "<B>The [src.name]</B> [pick("sulks down sadly", "sadly lowers its head")]."
			m_type = 1
		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> [pick("deftly", "quickly", "erotically", "joyfully")] moves its body."
				m_type = 1
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> falls on its back and[pick("", " cheerfully", " awkwardly")] rolls on the floor kinda like a kitten. [pick("Really cute.", "Very cute.", "So cute!")]"
				m_type = 1
				if(prob(50)) // xenomorphs are not kittens!
					to_chat(src, "<span class='warning'>You feel shame. [pick("You want to hunt, not waste time", "You're not an obedient girl", "You're not a good girl")].</span>")
		if("shake")
			message = "<B>The [src.name]</B> shakes its head [pick("like a true hunter", "and it seems to be grinning at you")]."
			m_type = 1
		if("grin")
			if (!muzzled)
				message = "<B>The [src.name]</B>[pick(" makes something like a smile and", "")] grinning its white[pick(" and crooked", " and slobbering", "")] teeth."
				m_type = 1
		if("jump")
			message = "<B>The [src.name]</B>[pick(" happily", " joyfully", "")] jumps!"
			m_type = 1
		if("help")
			to_chat(src, "<span class ='notice'>SOUNDED IN <B>BOLD</B>:   <B>deathgasp</B>, dance, drool, grin, jump, <B>happy_hiss</B>, <B>hiss</B>, nod, \
			                                        <B>roar</B>, roll, scratch, shake, sit, sway, tail, twitch, <B>whimper</B>, <B>growl</B></span>")
		else
			to_chat(src, "<span class='notice'>This action is not provided: [act]. Write \"*help\" to find out all available emotes. Write \"*me\" or \"*custom\" to do your own emote. \
			                   Otherwise, you can perform your action via the \"F4\" button.</span>")
	if(message)
		log_emote("[name]/[key] : [message]")
		for(var/mob/M in observer_list)
			if(!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)
		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if(m_type & 2)
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
