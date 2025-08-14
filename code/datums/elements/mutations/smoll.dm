// ELEMENT_TRAIT_SMOLL

/datum/element/mutation/smoll
	traits = list(
		TRAIT_VENTCRAWLER,
	)

/datum/element/mutation/smoll/on_gain(mob/living/L)
	L.mob_general_damage_mod.ModMultiplicative(2, src)

	L.update_size_class()

	L.pass_flags |= (PASSTABLE | PASSMOB)

	L.resize = VENTCRAWLER_RESIZE_VALUE
	L.update_transform()

	L.pixel_y -= VENTCRAWLER_SHIFT_Y_VALUE

	L.verbs += /mob/living/simple_animal/mouse/verb/hide

/datum/element/mutation/smoll/on_loose(mob/living/L)
	L.mob_general_damage_mod.RemoveMods(src)

	L.update_size_class()

	L.pass_flags &= ~(PASSTABLE | PASSMOB)

	L.density = initial(L.density)

	L.resize = 1 / VENTCRAWLER_RESIZE_VALUE
	L.update_transform()

	L.pixel_y += VENTCRAWLER_SHIFT_Y_VALUE

	L.verbs -= /mob/living/simple_animal/mouse/verb/hide
