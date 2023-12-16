SUBSYSTEM_DEF(preferences)
	name = "Preferences"
	wait = SS_WAIT_EXPLOSION
	flags = SS_TICKER | SS_SHOW_IN_MC_TAB//| SS_NO_INIT 

	wait = SS_WAIT_PREFERENCES

	var/list/processing = list()

/datum/controller/subsystem/preferences/stat_entry()
	..("PTS:[processing.len]")

/datum/controller/subsystem/preferences/mark_dirty(/datum/preferences/P)
// сделать вынос их процесс кеша обратно в очередь при изменении (демо?)

// другой вариант - сделать в префах обновляемый таймер SAVE, который будет отодвигаться при каждом новом изменении (может потерять дату?)
// PreShutdown & Shutdown - сбросить принудительно (можно добавить в FIRE новый флаг)

/datum/controller/subsystem/preferences/fire(resumed = 0)

/*
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
*/


// todo: /datum/controller/subsystem/preferences/update_all_preferences
