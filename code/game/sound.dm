/*=====================================================================================================================================
     === Explanation for some variables ===

var/is_global = if true then do not add echo to the sound
var/voluminosity = is that 3d sound? If false then ignore the coordinates of the sound(become a sort of mono sound)
var/src_vol = volume for its source. Separate sound volume for its source and for others? Make a "special" volume for the source?


     === Important notes for all soundmakers ===

* !!! DO NOT USE `<<` !!!. Use send_sound() instead of this.
* Before you create a new new channel, put it in a file which is located in [code\__DEFINES\sound.dm].

=======================================================================================================================================*/
/proc/playsound(atom/source, soundin, vol, vary, extrarange, falloff, channel = 0, is_global, wait = 0, voluminosity = TRUE, src_vol)
	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = get_rand_frequency() // Same frequency for everybody
	var/turf/turf_source = get_turf(source)

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if((M == source) && (src_vol != null))
			M.playsound_local(null, soundin, src_vol, vary, frequency, falloff, channel)
			continue

		var/distance = get_dist(M, turf_source)
		if(distance <= (world.view + extrarange) * 3)
			var/turf/T = get_turf(M)

			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, is_global, wait, voluminosity)

var/const/FALLOFF_SOUNDS = 0.5

/mob/proc/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, channel = 0, is_global, wait = 0, voluminosity = TRUE)
	if(!src.client || ear_deaf > 0)
		return FALSE
	soundin = get_sfx(soundin)

	var/sound/S = sound(soundin)
	//S.wait = 0 //No queue
	//S.channel = 0 //Any channel
	S.wait = wait
	S.channel = channel // Note. Channel 802 is busy with sound of automatic AI announcements
	S.volume = vol
	S.environment = -1
	if (vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		//sound volume falloff with pressure
		var/pressure_factor = 1.0

		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if (hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if (pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //in space
			pressure_factor = 0

		if (distance <= 1)
			pressure_factor = max(pressure_factor, 0.15)	//hearing through contact

		S.volume *= pressure_factor

		if (S.volume <= 0)
			return FALSE	//no volume means no sound

		if(voluminosity)
			var/dx = turf_source.x - T.x // Hearing from the right/left
			S.x = dx
			var/dz = turf_source.y - T.y // Hearing from infront/behind
			S.z = dz
			// The y value is for above your head, but there is no ceiling in 2d spessmens.
			S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)
	if(!is_global)
		S.environment = 2
	if(src.stat == UNCONSCIOUS || src.sleeping > 0) // unconscious people will hear illegible sounds
		S.volume /= 3
		S.environment = 10
	src << S

/mob/living/parasite/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, channel = 0, is_global)
	if(!host || host.ear_deaf > 0)
		return FALSE
	return ..()

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		send_sound(src, ticker.login_music, 85, CHANNEL_LOBBY_MUSIC) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/send_sound(target, sound, volume = 100, channel = 0, repeat = 0, wait = 0)
	var/sound/S = sound(sound)
	S.volume = volume
	S.channel = channel
	S.repeat = repeat
	S.wait = wait
	S.environment = 2 // To solve all environment problems in playsound() and playsound_local()
	target << S

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin) // Note. All lists of sounds of automatic AI announcements are located in *command_alert.dm*, *captain_announce.dm* and *security_levels.dm* files
			if ("shatter")
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if ("explosion")
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if ("sparks")
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if ("rustle")
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if ("bodyfall")
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if ("punch")
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if ("clownstep")
				soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if ("swing_hit")
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if ("pageturn")
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if ("desceration")
				soundin = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')
			if ("im_here")
				soundin = pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')
			if ("can_open")
				soundin = pick('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
			if ("law")
				soundin = pick('sound/voice/beepsky/god.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/beepsky/secureday.ogg', 'sound/voice/beepsky/radio.ogg', 'sound/voice/beepsky/insult.ogg', 'sound/voice/beepsky/creep.ogg')
			if ("bandg")
				soundin = pick('sound/items/bandage.ogg', 'sound/items/bandage2.ogg', 'sound/items/bandage3.ogg')
			if ("fracture")
				soundin = pick('sound/effects/bonebreak1.ogg', 'sound/effects/bonebreak2.ogg', 'sound/effects/bonebreak3.ogg', 'sound/effects/bonebreak4.ogg')
			if ("footsteps")
				soundin = pick('sound/effects/tile1.wav', 'sound/effects/tile2.wav', 'sound/effects/tile3.wav', 'sound/effects/tile4.wav')
			if ("rigbreath")
				soundin = pick('sound/misc/rigbreath1.ogg','sound/misc/rigbreath2.ogg','sound/misc/rigbreath3.ogg')
			if ("breathmask")
				soundin = pick('sound/misc/breathmask1.ogg','sound/misc/breathmask2.ogg')
			if ("gasmaskbreath")
				soundin = 'sound/misc/gasmaskbreath.ogg'
			if ("malevomit")
				soundin = pick('sound/misc/mvomit1.ogg','sound/misc/mvomit2.ogg')
			if ("femalevomit")
				soundin = pick('sound/misc/fvomit1.ogg','sound/misc/fvomit2.ogg')
			if ("frigvomit")
				soundin = pick('sound/misc/frigvomit1.ogg','sound/misc/frigvomit2.ogg')
			if ("mrigvomit")
				soundin = pick('sound/misc/mrigvomit1.ogg','sound/misc/mrigvomit2.ogg')
			if ("xenomorph_talk")
				soundin = pick('sound/voice/xenomorph/talk_1.ogg', 'sound/voice/xenomorph/talk_2.ogg', 'sound/voice/xenomorph/talk_3.ogg', 'sound/voice/xenomorph/talk_4.ogg')
			if ("xenomorph_roar")
				soundin = pick('sound/voice/xenomorph/roar_1.ogg', 'sound/voice/xenomorph/roar_2.ogg')
			if ("xenomorph_hiss")
				soundin = pick('sound/voice/xenomorph/hiss_1.ogg', 'sound/voice/xenomorph/hiss_2.ogg', 'sound/voice/xenomorph/hiss_3.ogg')
			if ("xenomorph_growl")
				soundin = pick('sound/voice/xenomorph/growl_1.ogg', 'sound/voice/xenomorph/growl_2.ogg')
			if ("keyboard")
				soundin = pick('sound/machines/keyboard/keyboard1.ogg', 'sound/machines/keyboard/keyboard2.ogg', 'sound/machines/keyboard/keyboard3.ogg', 'sound/machines/keyboard/keyboard4.ogg', 'sound/machines/keyboard/keyboard5.ogg')
			if ("pda")
				soundin = pick('sound/machines/keyboard/pda1.ogg', 'sound/machines/keyboard/pda2.ogg', 'sound/machines/keyboard/pda3.ogg', 'sound/machines/keyboard/pda4.ogg', 'sound/machines/keyboard/pda5.ogg')
	return soundin
