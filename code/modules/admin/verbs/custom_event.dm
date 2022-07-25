#define CUSTOM_EVENT_MESSAGE_FORMATTED SSticker && SSticker.custom_event_msg && "<h1 class='alert'>Custom Event</h1><br>\
	<h2 class='alert'>A custom event is taking place. OOC Info:</h2><br>\
	<span class='alert'>[SSticker.custom_event_msg]</span><br>\
	<br>"

// verb for admins to set custom event
/client/proc/cmd_admin_change_custom_event()
	set category = "Event"
	set name = "Change Custom Event"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = sanitize(input(usr, "Enter the description of the custom event. Be descriptive. To cancel the event, make this blank or hit cancel.", "Custom Event", input_default(SSticker.custom_event_msg)) as message|null, MAX_BOOK_MESSAGE_LEN, extra = FALSE)
	if(!input || input == "")
		SSticker.custom_event_msg = null
		log_admin("[key_name(usr)] has cleared the custom event text.")
		message_admins("[key_name_admin(usr)] has cleared the custom event text.")
		return

	log_admin("[key_name(usr)] has changed the custom event text.")
	message_admins("[key_name_admin(usr)] has changed the custom event text.")

	SSticker.custom_event_msg = input

	to_chat(world, CUSTOM_EVENT_MESSAGE_FORMATTED)

	if(config.chat_bridge && \
		tgui_alert(usr, "Do you want to make an announcement to chat conference?", "Chat announcement", list("Yes", "No, I don't want these people at my party")) == "Yes")
		world.send2bridge(
			type = list(BRIDGE_ANNOUNCE),
			attachment_title = "Custom Event",
			attachment_msg = SSticker.custom_event_msg + "\nJoin now: <[BYOND_JOIN_LINK]>",
			attachment_color = BRIDGE_COLOR_ANNOUNCE,
			mention = BRIDGE_MENTION_EVENT,
		)

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	if(!SSticker.custom_event_msg || SSticker.custom_event_msg == "")
		to_chat(src, "There currently is no known custom event taking place.")
		to_chat(src, "Keep in mind: it is possible that an admin has not properly set this.")
		return

	to_chat(src, CUSTOM_EVENT_MESSAGE_FORMATTED)

