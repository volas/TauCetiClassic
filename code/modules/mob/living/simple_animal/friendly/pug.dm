//Corgi
/mob/living/simple_animal/pug
	name = "pug"
	real_name = "pug"
	desc = "It's a pug."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes its head", "chases its tail","shivers")
	speak_chance = 1
	turns_per_move = 10
	w_class = SIZE_NORMAL
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/pug = 3)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	see_in_dark = 5

	has_head = TRUE
	has_leg = TRUE

	default_emotes = list(
		/datum/emote/dance,
	)

/mob/living/simple_animal/pug/Life()
	..()

	if(!stat && !buckled)
		if(prob(1))
			emote("dance")

/mob/living/simple_animal/pug/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/weapon/newspaper))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!stat)
			user.visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O]</span>")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					set_dir(i)
					sleep(1)
	else
		..()

//Agent F
/mob/living/simple_animal/pug/frank
	name = "Frank"
	real_name = "Frank"
	desc = "It's a pug. Not at all suspicious, pug."
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "Who let the dogs out?! Woof, woof, woof, woof, woof!", "Grrrrr... Bark! Bark! Bark!", "You humans! When will you learn size doesn't matter? Just because something's important, doesn't mean it's not very small.", "How about we do the good cop, bad cop routine? You can interrogate the witness, and I'll just growl. Grrrrr...", "Listen, partner. I may look like a dog, but I'm only play one here.")
	speak_emote = list("says", "barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps", "pants", "looks around", "adjusts the skin")
	emote_see = list("shakes its head", "chases its tail", "shivers", "laughs", "pretends to be a dog", "hums a pop song")
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 3)
