/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in world)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  next_click = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0
	message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!", 1)
	message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!", 1)
	message_admins("world.time = [world.time]")
	feedback_add_details("admin_verb","UFE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/filters = list(
		"1" = "RADIO_TO_AIRALARM",
		"2" = "RADIO_FROM_AIRALARM",
		"3" = "RADIO_CHAT",
		"4" = "RADIO_ATMOSIA",
		"5" = "RADIO_NAVBEACONS",
		"6" = "RADIO_AIRLOCK",
		"7" = "RADIO_SECBOT",
		"8" = "RADIO_MULEBOT",
		"_default" = "NO_FILTER"
		)
	var/output = ""
	for (var/fq in radio_controller.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/datum/radio_frequency/fqs = radio_controller.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if (!f)
				output += "&nbsp;&nbsp;[filters[filter]]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filters[filter]]: [f.len]<br>"
			for (var/device in f)
				if (isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	var/datum/browser/popup = new(usr, "radioreport", "Radio Report")
	popup.set_content(output)
	popup.open()

	feedback_add_details("admin_verb","RR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	message_admins("[key_name_admin(usr)] manually reloaded admins")
	log_debug("[key_name(usr)] manually reloaded admins")
	load_admins()
	feedback_add_details("admin_verb","RLDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_mentors()
	set name = "Reload Mentors"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	message_admins("[key_name_admin(usr)] manually reloaded mentors")
	log_debug("[key_name(usr)] manually reloaded mentors")
	world.load_mentors()

/client/proc/reload_config()
	set name = "Reload Configuration"
	set category = "Debug"

	if (!check_rights(R_PERMISSIONS))
		return

	message_admins("[key_name_admin(usr)] manually reloaded configuration")
	log_debug("[key_name(usr)] manually reloaded configuration")
	world.load_configuration()

/client/proc/force_dropship()
	set category = "Debug"
	set name = "Force Dropship"

	var/list/available_shuttles = list()
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		available_shuttles["[M.name] ([M.id])"] = M.id

	var/answer = tgui_input_list(usr, "Which shuttle do you want to move?", "Force Dropship", available_shuttles)
	var/shuttle_id = available_shuttles[answer]
	if(!shuttle_id)
		return

	var/obj/docking_port/mobile/D
	for(var/i in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = i
		if(M.id == shuttle_id)
			D = M

	if(!D)
		to_chat(usr, "<span class='warning'>Unable to find shuttle</>")
		return

	if(D.mode != SHUTTLE_IDLE && tgui_alert(usr, "[D.name] is not idle, move anyway?", "Force Dropship", list("Yes", "No")) != "Yes")
		return

	var/list/valid_docks = list()
	var/i = 1
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(istype(S, /obj/docking_port/stationary/transit))
			continue // Don't use transit destinations
		if(!D.check_dock(S, silent=TRUE))
			continue
		valid_docks["[S.name] ([i++])"] = S

	if(!length(valid_docks))
		to_chat(usr, "<span class='warning'>No valid destinations found!</>")
		return

	var/dock = tgui_input_list(usr, "Choose the destination.", "Force Dropship", valid_docks)
	if(!dock)
		return

	var/obj/docking_port/stationary/target = valid_docks[dock]
	if(!target)
		to_chat(usr, "<span class='warning'>No valid dock found!</>")
		return

	var/instant = FALSE
	if(tgui_alert(usr, "Do you want to move the [D.name] instantly?", "Force Dropship", list("Yes", "No")) == "Yes")
		instant = TRUE

	var/success = SSshuttle.moveShuttleToDock(D.id, target, !instant)
	switch(success)
		if(0)
			success = "successfully"
		if(1)
			success = "failing to find the shuttle"
		if(2)
			success = "failing to dock"
		else
			success = "failing somehow"

	log_admin("[key_name(usr)] has moved [D.name] ([D.id]) to [target] ([target.id])[instant ? " instantly" : ""] [success].")

