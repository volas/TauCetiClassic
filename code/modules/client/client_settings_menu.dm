/client
	var/datum/client_settings/settings

/client/verb/client_settings()
	set name = "#prefs"
	set category = "Preferences"

	if(!prefs_ready)
		to_chat(usr, "Need more time for initialization!")
		return

	if(!settings)
		settings = new /datum/client_settings(src)
	settings.tgui_interact(usr)

/datum/client_settings
	var/tab = "audio"

/datum/client_settings/tgui_interact(mob/user, datum/tgui/ui)
	world.log << "tgui_interact"
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		world.log << "open"
		ui = new(user, src, "ClientSettings", "Client Settings")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/client_settings/tgui_data(mob/user)
	var/list/data = list("active_tab" = tab, "settings" = list())

	//for(var/datum/pref/player/P as anything in user.client.prefs.get_category_preferences(tab))
	for(var/type in user.client.prefs.player_settings)
		var/datum/pref/player/P = user.client.prefs.player_settings[type]
		//if(P.category != tab)
		//	continue
		data["settings"] += list(list("type" = "[P.type]", "name" = P.name, "description" = P.description, "value" = P.value, "v_type" = P.value_type, "v_variations" = P.value_variations))

	world.log << length(data["settings"])
	world.log << json_encode(data)


	return data

///datum/client_settings/tgui_static_data(mob/user)
//	return data


// var/static/settings - разместить общие настройки, без value?

/*
  const tabs = {
    ui: "Интерфейс",
    graphics: "Графика",
    audio: "Аудио",
    chat: "Чат",
    other: "Разное",
    keybinds: "Управление",
  };


*/

/datum/client_settings/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	var/client/C = ui.user.client

	switch(action)
		if("set_value")
			C.prefs.write_preference(params["type"], params["value"])
			. = TRUE

	return TRUE

/datum/client_settings/tgui_state(mob/user)
	return global.always_state //global.admin_state
