/datum/pref/player/effects
	category = PREF_PLAYER_EFFECTS

/datum/pref/player/effects/ambientocclusion
	name = "Окружающее затенение"
	description = "Добавляет затенение для объектов в игре, помогает придать объем изображению."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/effects/ambientocclusion/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/game_world)

/datum/pref/player/effects/parallax
	name = "Качество параллакса"
	description = "Качество анимации фонов в космосе. На высоких настройках может негативно влиять на производительность."
	value_type = PREF_TYPE_SELECT
	value = PARALLAX_HIGH
	value_parameters = list(
		PARALLAX_DISABLE = "Выключено", 
		PARALLAX_LOW = "Низкое", 
		PARALLAX_MED = "Среднее", 
		PARALLAX_HIGH = "Высокое", 
		PARALLAX_INSANE = "Безумное"
	)

/datum/pref/player/effects/parallax/on_update(client/client, old_value)
	if(client?.mob?.hud_used)
		client.mob.hud_used.update_parallax_pref()

/datum/pref/player/effects/glowlevel // aka light sources bloom
	name = "Уровень свечения"
	description = "Добавляет легкий блюр источникам света. Подберите значение на свой вкус."
	value_type = PREF_TYPE_SELECT
	value = GLOW_MED
	value_parameters = list(
		GLOW_DISABLE = "Выключено", 
		GLOW_LOW = "Низкое", 
		GLOW_MED = "Среднее", 
		GLOW_HIGH = "Высокое"
	)

/datum/pref/player/effects/glowlevel/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/lamps_selfglow)

/datum/pref/player/effects/lampsexposure // still idk how to name it properly, spot light effect?
	name = "Направленный свет от ламп"
	description = "Визуально улучшает свет от ламп. Может влиять на производительность."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/effects/lampsexposure/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/exposure)

/datum/pref/player/effects/lampsglare
	name = "Блик на источниках света"
	description = "На случай, если вы фанат Джей Джей Абрамса."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/effects/lampsglare/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/lamps_glare)

/datum/pref/player/effects/legacy_blur
	name = "Старый блюр зрения"
	description = "Использовать старый, менее затратный для производительности, эффект для повреждения/помех зрения персонажа."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/effects/legacy_blur/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/game_world)

/datum/pref/player/effects/lobbyanimation
	name = "Анимация экрана лобби"
	description = "Включает анимированное лобби. На некоторых системах может лагать."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/effects/lobbyanimation/on_update(client/client, old_value)
	if(client && isnewplayer(client.mob))
		var/mob/dead/new_player/M = client.mob
		M.show_titlescreen()
