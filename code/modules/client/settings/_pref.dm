/*preferences -> [pref]

db -> preferences -> [pref]*/

///datum/prefs_domain
// 	db_suffix = "player"
// 	folder_suffix = "player"
// 	лучше хардкодом, безопаснее

/datum/pref
	// related to json name (or table in DB)
	var/domain // player | character | keybinds | meta 
	// first key in JSON and category name in menu
	var/category
	// second key in JSON and option name in menu
	var/name

	var/description

	// default value, will be overriden with client value
	var/value

	// for frontend
	var/value_type // = COLOR | NUMBER | LIST | BOOLEAN | TEXT
	// (think again) depending on type, it can be list(min, max) or list of choices
	var/list/value_variations
	//var/value_default

	//validation// = COLOR | NUMBER | LIST | BOOLEAN | TEXT

// валидация значения - по типу?

// todo:
// /datum/pref/character
// 	type = "character"

/datum/pref/proc/sanitize_value(new_value)
	PRIVATE_PROC(TRUE)

	CRASH("Not implemented sanitize_value for [src.type]!")
	return FALSE

/datum/pref/proc/get_value(new_value, client/parent)
	SHOULD_NOT_OVERRIDE(TRUE)

	return value

/datum/pref/proc/set_value(new_value, client/parent)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/old_value = value
	value = sanitize_value(new_value)

	world.log << "[type] new value: [value]"

	if(old_value != value)
		on_update(parent, old_value)

/datum/pref/proc/set_default(client/parent)
	SHOULD_NOT_OVERRIDE(TRUE)

	set_value(initial(value), parent)

// override if you need to trigger any special updates after setting changed (reload planes, update sound volume, etc.)
/datum/pref/proc/on_update(client/parent, old_value) // apply_change
	PRIVATE_PROC(TRUE)

	return FALSE
