	////////////
	//SECURITY//
	////////////
#define LIMITER_SIZE	5
#define CURRENT_SECOND	1
#define SECOND_COUNT	2
#define CURRENT_MINUTE	3
#define MINUTE_COUNT	4
#define ADMINSWARNED_AT	5

#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?

var/global/list/blacklisted_builds = list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",
	"1434" = "bug turf images weren't reapplied properly when moving around the map",
	"1468" = "bug with screen-loc mouse parameter (x and y axis were switched) and several mouse hit problems",
	"1469" = "bug with screen-loc mouse parameter (x and y axis were switched) and several mouse hit problems"
	)

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if(!asset_cache_job)
			return

	//Reduces spamming of links by dropping calls that happen during the delay period
	if (!holder && config.minutetopiclimit)
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > config.minutetopiclimit)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [config.minutetopiclimit] topic calls in a given game minute.")
				message_admins("[ADMIN_LOOKUPFLW(usr)] [ADMIN_KICK(usr)] Has hit the per-minute topic limit of [config.minutetopiclimit] topic calls in a given game minute.")
			to_chat(src, "<span class='danger'>[msg]</span>")
			return

	if (!holder && config.secondtopiclimit)
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > config.secondtopiclimit)
			to_chat(src, "<span class='danger'>Your previous action was ignored because you've done too many in a second.</span>")
			return

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		return

	if (href_list["action"] && href_list["action"] == "jsErrorCatcher" && href_list["file"] && href_list["message"])
		var/file = href_list["file"]
		var/message = href_list["message"]
		js_error_manager.log_error(file, message, src)
		return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return
	if(href_list["reload_tguipanel"])
		nuke_chat()

	//Logs all hrefs
	log_href("[src] (usr:[usr]\[[COORD(usr)]\]) || [hsrc ? "[hsrc] " : ""][href]")

	//byond bug ID:2256651
	if(asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
		src << browse("...", "window=asset_cache_browser")
		return
	if(href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	//byond bug ID:2694120
	if(href_list["reset_macros"])
		reset_macros(skip_alert = TRUE)
		return

	// Keypress passthrough
	if(href_list["__keydown"])
		var/keycode = browser_keycode_to_byond(href_list["__keydown"])
		if(keycode)
			keyDown(keycode)
		return
	if(href_list["__keyup"])
		var/keycode = browser_keycode_to_byond(href_list["__keyup"])
		if(keycode)
			keyUp(keycode)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		if(href_list["ahelp_reply"])
			cmd_ahelp_reply(C, text2num(href_list["ahelp_reply"]))
			return
		if(href_list["mentor_pm"])
			cmd_mentor_pm(C)
			return
		cmd_admin_pm(C,null)
		return

	if(href_list["metahelp"])
		show_metahelp_message(href_list["metahelp"])
		return

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)
		if("updateVolume")	return update_volume(href_list)

	switch(href_list["action"])
		if ("openLink")
			src << link(href_list["link"])

	..()	//redirect to hsrc.Topic()

#undef ADMINSWARNED_AT
#undef MINUTE_COUNT
#undef CURRENT_MINUTE
#undef SECOND_COUNT
#undef CURRENT_SECOND
#undef LIMITER_SIZE

/client/Destroy()
	..() // Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW

/client/proc/handle_spam_prevention(message, mute_type)
	if(global_message_cooldown && (world.time < last_message_time + 5))
		return 1
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='warning'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			spam_automute(src.mob, mute_type)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='warning'>You are nearing the spam filter limit for identical messages.</span>")
			return 0
	else
		last_message_time = world.time
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1

/proc/spam_automute(mob/M as mob, mute_type)
	if(!config.automute_on)
		return

	if(!M.client)
		return

	var/muteunmute = "auto-muted"
	var/mute_string = get_mute_text(mute_type)

	if(!mute_string)
		CRASH("Can't parse mute type: [mute_type]")

	M.client.prefs.muted |= mute_type
	log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].")
	to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
	feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/get_mute_text(mute_type)
	switch(mute_type)
		if(MUTE_IC)
			. = "IC (say and emote)"
		if(MUTE_OOC)
			. = "OOC"
		if(MUTE_PRAY)
			. = "pray"
		if(MUTE_ADMINHELP)
			. = "adminhelp, admin PM and ASAY"
		if(MUTE_MENTORHELP)
			. = "mentorhelp and mentor PM"
		if(MUTE_DEADCHAT)
			. = "deadchat and DSAY"
		if(MUTE_ALL)
			. = "everything"
		else
			return


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	var/tdata = TopicData //save this for later use
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker")					//Invalid connection type.
		return null

	if(!guard)
		guard = new(src)

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	to_chat(src, "<span class='warning'>If the title screen is black, resources are still downloading. Please be patient until the title screen appears.</span>")


	clients += src
	directory[ckey] = src

	// Instantiate tgui panel
	tgui_panel = new(src)

	global.ahelp_tickets?.ClientLogin(src)

	//Admin Authorisation
	holder = admin_datums[ckey]

	if(config.sandbox)
		var/sandbox_permissions = (R_HOST & ~(R_PERMISSIONS | R_DEBUG | R_BAN | R_LOG))
		if(!holder)
			new /datum/admins(ADMIN_RANK_SANDBOX, sandbox_permissions, ckey)
			holder = admin_datums[ckey]
		else
			holder.rights = (holder.rights | sandbox_permissions)

	if(holder)
		holder.owner = src
		admins += src
		if(holder.deadminned)
			holder.disassociate()
			verbs += /client/proc/readmin_self

	if(ckey in mentor_ckeys)
		mentors += src

	update_supporter_status()

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(prefs)
		prefs.parent = src
	else
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning
	fps = (prefs.clientfps < 0) ? RECOMMENDED_FPS : prefs.clientfps

	var/cur_date = time2text(world.realtime, "YYYY/MM/DD hh:mm:ss")
	if("[computer_id]" in prefs.cid_list)
		prefs.cid_list["[computer_id]"]["last_seen"] = cur_date
	else
		prefs.cid_list["[computer_id]"] = list("first_seen"=cur_date, "last_seen"=cur_date)

	if(prefs.cid_list.len > 2)
		log_admin("[ckey] has [prefs.cid_list.len] different computer_id.")
		message_admins("[ckey] has <span class='red'>[prefs.cid_list.len]</span> different computer_id.")

	prefs.save_preferences()

	prefs_ready = TRUE // if moved below parent call, Login feature with lobby music will be broken and maybe anything else.

	. = ..()	//calls mob.Login()

	if(SSinput.initialized)
		set_macros()

	// Initialize tgui panel
	tgui_panel.initialize()

	connection_time = world.time

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[custom_event_msg]</span>")
		to_chat(src, "<br>")

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()
		if(holder.rights & R_BAN)
			// fluff needs rewiew
			var/list/fluff_list = custom_item_premoderation_list()
			var/fluff_count = fluff_list.len
			if(fluff_count)
				to_chat(src, "<span class='alert bold'>В рассмотрении [pluralize_russian(fluff_count, "нуждается [fluff_count] флафф-предмет", "нуждаются [fluff_count] флафф-предмета", "нуждаются [fluff_count] флафф-предметов")]. Вы можете просмотреть [pluralize_russian(fluff_count, "его", "их")] в панели 'Whitelist Custom Items'.</span>")

		if(holder.rights & R_PERMISSIONS)
			// library needs rewiew
			var/library_count = library_needs_rewiew()
			if(library_count)
				to_chat(src, "<span class='alert bold'>На [library_count] [pluralize_russian(library_count, "книгу", "книги", "книг")] библиотеки поступили жалобы. Проверьте в панели 'Library: Recycle bin'</span>")

	if (supporter)
		to_chat(src, "<span class='info bold'>Hello [key]! Thanks for supporting [(ckey in donators) ? "us" : "Byond"]! You are awesome! You have access to all the additional supporters-only features this month.</span>")

	log_client_to_db(tdata)

	send_resources()

	generate_clickcatcher()

	// Set config based title for main window
	if (config.server_name)
		winset(src, "mainwindow", "title='[world.name]: [config.server_name]'")
	else
		winset(src, "mainwindow", "title='[world.name]'")

	if(prefs.lastchangelog != changelog_hash) // Bolds the changelog button on the interface so we know there are updates.
		to_chat(src, "<span class='info'>You have unread updates in the changelog.</span>")
		winset(src, "rpane.changelog", "font-style=bold")

		//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	if(prefs.auto_fit_viewport)
		fit_viewport()

	if(!cob)
		cob = new()

	if(!media)
		media = new(src)

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, \
		if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. \
		This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")

	handle_connect()

	spawn(50)//should wait for goonchat initialization for kick/redirect reasons
		if(!handle_autokick_reasons())
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CLIENT_CONNECT, src)

	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	for(var/window_id in browsers)
		qdel(browsers[window_id])

	log_client_ingame_age_to_db()
	if(cob && cob.in_building_mode)
		cob.remove_build_overlay(src)
	if(holder)
		holder.owner = null
		admins -= src
	global.ahelp_tickets?.ClientLogout(src)
	directory -= ckey
	mentors -= src
	clients -= src
	QDEL_LIST_ASSOC_VAL(char_render_holders)
	LAZYREMOVE(movingmob?.clients_in_contents, src)

	handle_leave()

	if(!gc_destroyed) //Clean up signals and timers.
		Destroy()

	return ..()

// return TRUE if we need to kick/redirect player, else FALSE
/client/proc/handle_autokick_reasons()
	if(config.client_limit_panic_bunker_count != null)

		if(clients.len > config.client_limit_panic_bunker_count)
			var/blocked_by_bunker = TRUE

			if(ckey in admin_datums) // admins immune to bunker
				blocked_by_bunker = FALSE

			if(supporter) // and patrons
				blocked_by_bunker = FALSE

			if(ckey in joined_player_list) // player already joined the game and just reconnects, so we pass him
				blocked_by_bunker = FALSE

			if((ckey in mentor_ckeys) && length(mentors) <= config.client_limit_panic_bunker_mentor_pass_cap) // mentors immune too, but only before own cap
				blocked_by_bunker = FALSE

			if(blocked_by_bunker)
				if (config.client_limit_panic_bunker_link)
					to_chat(src, "<span class='notice'>Player limit is enabled. You are redirected to [config.client_limit_panic_bunker_link].</span>")
					SEND_LINK(src, config.client_limit_panic_bunker_link)
					log_access("Failed Login: [key] [computer_id] [address] - redirected by limit bunker to [config.client_limit_panic_bunker_link]")
				else
					to_chat(src, "<span class='danger'>Sorry, player limit is enabled. Try to connect later.</span>")
					log_access("Failed Login: [key] [computer_id] [address] - blocked by panic bunker")
					QDEL_IN(src, 2 SECONDS)
				return TRUE

	if(config.registration_panic_bunker_age)
		if(!(ckey in admin_datums) && !(src in mentors) && is_blocked_by_regisration_panic_bunker())
			to_chat(src, "<span class='danger'>Sorry, but server is currently not accepting new players. Try to connect later.</span>")
			message_admins("<span class='adminnotice'>[key_name(src)] has been blocked by panic bunker. Connection rejected.</span>")
			log_access("Failed Login: [key] [computer_id] [address] - blocked by panic bunker")
			QDEL_IN(src, 2 SECONDS)
			return TRUE

	if(config.byond_version_min && byond_version < config.byond_version_min)
		popup(src, "Your version of Byond is too old. Update to the [config.byond_version_min] or later for playing on our server.", "Byond Verion")
		to_chat(src, "<span class='warning bold'>Your version of Byond is too old. Update to the [config.byond_version_min] or later for playing on our server.</span>")
		log_access("Failed Login: [key] [computer_id] [address] - byond version less that minimal required: [byond_version].[byond_build])")
		if(!holder)
			QDEL_IN(src, 2 SECONDS)
			return TRUE

	if(config.byond_version_recommend && byond_version < config.byond_version_recommend)
		to_chat(src, "<span class='warning bold'>Your version of Byond is less that recommended. Update to the [config.byond_version_recommend] for better experiense.</span>")

	if((byond_version >= 512 && (!byond_build || byond_build < 1421)) || (num2text(byond_build) in blacklisted_builds))
		to_chat(src, "<span class='warning bold'>You are using the inappropriate Byond version. Update to the latest Byond version or install another from http://www.byond.com/download/build/ for playing on our server.</span>")
		message_admins("<span class='adminnotice'>[key_name(src)] has been detected as using a inappropriate byond version: [byond_version].[byond_build]. Connection rejected.</span>")
		log_access("Failed Login: [key] [computer_id] [address] - inappropriate byond version: [byond_version].[byond_build])")
		if(!holder)
			QDEL_IN(src, 2 SECONDS)
			return TRUE


/client/proc/log_client_to_db(connectiontopic)

	if ( IsGuestKey(src.key) )
		return

	if(!establish_db_connection("erro_player"))
		return

	var/sql_ckey = ckey(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age, ingameage FROM erro_player WHERE ckey = '[sql_ckey]'")

	if(!query.Execute()) // for some reason IsConnected() sometimes ignores disconnections
		return           // dbcore revision needed

	var/sql_id = 0
	var/sql_player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	var/sql_player_ingame_age = 0
	while(query.NextRow())
		sql_id = query.item[1]
		sql_player_age = text2num(query.item[2])
		sql_player_ingame_age = text2num(query.item[3])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[sanitize_sql(address)]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		if(src.ckey == query_ip.item[1])
			continue
		if(length(related_accounts_ip))
			related_accounts_ip += ", "
		related_accounts_ip += "[query_ip.item[1]]"
		break

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[sanitize_sql(computer_id)]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		if(src.ckey == query_cid.item[1])
			continue
		if(length(related_accounts_cid))
			related_accounts_cid += ", "
		related_accounts_cid += "[query_cid.item[1]]"
		break

	var/admin_rank = "Player"
	if (src.holder)
		admin_rank = src.holder.rank
	else if (config.check_randomizer && check_randomizer(connectiontopic))
		return

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/sql_ip = sanitize_sql(src.address)
	var/sql_computerid = sanitize_sql(src.computer_id)
	var/sql_admin_rank = sanitize_sql(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else if(!config.bunker_ban_mode)
		//New player!! Need to insert all the stuff
		guard.first_entry = TRUE
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank, ingameage) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]', '[sql_player_ingame_age]')")
		query_insert.Execute()

	player_age = sql_player_age
	player_ingame_age = sql_player_ingame_age

	//Logging player access
	if(establish_db_connection("erro_connection_log"))
		var/serverip = sanitize_sql("[world.internet_address]:[world.port]")
		var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
		query_accesslog.Execute()

/client/proc/check_randomizer(topic)
	. = FALSE
	if (connection != "seeker")
		return
	topic = params2list(topic)
	var/static/cidcheck = list()
	var/static/tokens = list()
	var/static/cidcheck_failedckeys = list() //to avoid spamming the admins if the same guy keeps trying.
	var/static/cidcheck_spoofckeys = list()

	var/oldcid = cidcheck[ckey]

	if (oldcid)
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] appears to have attempted to spoof a cid randomizer check.</span>")
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(10) //browse is queued, we don't want them to disconnect before getting the browse() command.
			qdel(src)
			return TRUE

		if (oldcid != computer_id) //IT CHANGED!!!
			cidcheck -= ckey //so they can try again after removing the cid randomizer.

			to_chat(src, "<span class='userdanger'>Connection Error:</span>")
			to_chat(src, "<span class='danger'>Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your byond installation and try again.</span>")

			if (!cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] has been detected as using a cid randomizer. Connection rejected.</span>")
				world.send2bridge(
					type = list(BRIDGE_ADMINLOG),
					attachment_title = "Cid Randomizer",
					attachment_msg = "**[key_name(src)]** has been detected as using a cid randomizer. Connection rejected.",
					attachment_color = BRIDGE_COLOR_ADMINLOG,
				)

				cidcheck_failedckeys[ckey] = TRUE
				notes_add(ckey, "Detected as using a cid randomizer.")

			log_access("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			qdel(src)
			return TRUE
		else
			if (cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer</span>")
				world.send2bridge(
					type = list(BRIDGE_ADMINLOG),
					attachment_title = "Cid Randomizer",
					attachment_msg = "**[key_name(src)]** has been allowed to connect after showing they removed their cid randomizer",
					attachment_color = BRIDGE_COLOR_ADMINLOG,
				)
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time</span>")
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey
	else
		var/sql_ckey = ckey(ckey)
		var/DBQuery/query_cidcheck = dbcon.NewQuery("SELECT computerid FROM erro_player WHERE ckey = '[sql_ckey]'")
		query_cidcheck.Execute()

		var/lastcid
		if (query_cidcheck.NextRow())
			lastcid = query_cidcheck.item[1]

		if (computer_id != lastcid)
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(10) //browse is queued, we don't want them to disconnect before getting the browse() command.
			qdel(src)
			return TRUE

/client/proc/cid_check_reconnect()
	var/token = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_access("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse("<a id='link' href='byond://[url]?token=[token]'>byond://[url]?token=[token]</a><script type='text/javascript'>document.getElementById(\"link\").click();window.location=\"byond://winset?command=.quit\"</script>", "border=0;titlebar=0;size=1x1")
	to_chat(src, "<a href='byond://[url]?token=[token]'>You will be automatically taken to the game, if not, click here to be taken manually</a>")

/client/proc/log_client_ingame_age_to_db()
	if ( IsGuestKey(src.key) )
		return

	if(!establish_db_connection("erro_player"))
		return

	if(!isnum(player_ingame_age))
		return

	if(player_ingame_age <= 0)
		return

	var/sql_ckey = ckey(src.ckey)
	var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET ingameage = '[player_ingame_age]' WHERE ckey = '[sql_ckey]' AND cast(ingameage as unsigned integer) < [player_ingame_age]")
	query_update.Execute()

#undef UPLOAD_LIMIT

/client/Click(atom/object, atom/location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers[DRAG])
		return
	if (prefs.hotkeys)
		winset(src, null, "input.background-color=[COLOR_INPUT_DISABLED]")
	else
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")

	..()

/client/proc/is_afk(duration = config.afk_time_bracket)
	return inactivity > duration

/client/proc/inactivity2text()
	var/seconds = inactivity / 10
	return "[round(seconds / 60)] minute\s, [seconds % 60] second\s"

// Send resources to the client.
/client/proc/send_resources()
	// Most assets are now handled through asset_cache.dm
	getFiles(
		'html/search.js', // Used in various non-NanoUI HTML windows for search functionality
		'html/panels.css' // Used for styling certain panels, such as in the new player panel
	)

	spawn (10) //removing this spawn causes all clients to not get verbs.

		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")

		//Precache the client with all other assets slowly, so as to not block other browse() calls
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(getFilesSlow), src, SSassets.preload, FALSE), 5 SECONDS)

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
		screen += void

/client/proc/show_character_previews(mutable_appearance/MA)
	var/pos = 0
	for(var/D in cardinal)
		pos++
		var/atom/movable/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			screen |= O
		O.appearance = MA
		O.set_dir(D)
		var/image/floor = image('icons/turf/floors.dmi', icon_state="floor")
		floor.appearance_flags |= KEEP_APART
		O.underlays += floor
		O.screen_loc = "character_preview_map:0,[pos]"

/client/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/atom/movable/screen/S = char_render_holders[index]
		screen -= S
		qdel(S)
	char_render_holders = null

/client/proc/get_byond_registration()
	if(byond_registration)
		return byond_registration

	return get_byond_registration_from_pager(ckey)

/proc/get_byond_registration_from_pager(ckey)
	ckey = ckey(ckey)
	if(!ckey)
		return

	var/user_page = get_webpage("http://www.byond.com/members/[ckey]?format=text")

	if (!user_page)
		return

	var/static/regex/joined_date_regex = regex("joined = \"(\\d+)-(\\d+)-(\\d+)\"")
	joined_date_regex.Find(user_page)

	return list(text2num(joined_date_regex.group[1]), text2num(joined_date_regex.group[2]), text2num(joined_date_regex.group[3]))

/client/proc/GetRolePrefs()
	var/list/roleprefs = list()
	for(var/role_id in antag_roles)
		if(role_id in prefs.be_role)
			roleprefs += role_id
	if(!roleprefs.len)
		return "none"
	return get_english_list(roleprefs)

/**
 * Updates the keybinds for special keys
 *
 * Handles adding macros for the keys that need it
 * And adding movement keys to the clients movement_keys list
 * At the time of writing this, communication(OOC, Say, IC) require macros
 * Arguments:
 * * direct_prefs - the preference we're going to get keybinds from
 */
/client/proc/update_special_keybinds(datum/preferences/direct_prefs)
	var/datum/preferences/D = prefs || direct_prefs
	if(!D?.key_bindings)
		return
	movement_keys = list()
	var/list/communication_hotkeys = list()
	for(var/key in D.key_bindings)
		for(var/kb_name in D.key_bindings[key])
			switch(kb_name)
				if("North")
					movement_keys[key] = NORTH
				if("East")
					movement_keys[key] = EAST
				if("West")
					movement_keys[key] = WEST
				if("South")
					movement_keys[key] = SOUTH
				if("Say")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=.say") // ".say" is wrapper over say, see in code\modules\mob\typing_indicator.dm
					communication_hotkeys += key
				if("OOC")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=ooc")
					communication_hotkeys += key
				if("Me")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=.me")
					communication_hotkeys += key
				if("LOOC")
					winset(src, "default-\ref[key]", "parent=default;name=[key];command=looc")
					communication_hotkeys += key

	// winget() does not work for F1 and F2
	for(var/key in communication_hotkeys)
		if(!(key in list("F1","F2")) && !winget(src, "default-\ref[key]", "command"))
			to_chat(src, "Вероятно Вы вошли в игру с русской раскладкой клавиатуры.\n<a href='?src=\ref[src];reset_macros=1'>Пожалуйста, переключитесь на английскую раскладку и кликните сюда, чтобы исправить хоткеи коммуникаций.</a>")
			break

#define MAXIMAZED  (1<<0)
#define FULLSCREEN (1<<1)

/client/verb/toggle_fullscreen()
	set name = "Toggle Fullscreen"
	set category = "OOC"

	fullscreen ^= FULLSCREEN

	if(fullscreen & FULLSCREEN)
		if(winget(usr, "mainwindow", "is-maximized") == "true")
			fullscreen |= MAXIMAZED
		else
			fullscreen &= ~MAXIMAZED
		winset(usr, "mainwindow", "titlebar=false")
		winset(usr, "mainwindow", "can-resize=false")
		winset(usr, "mainwindow", "is-maximized=false")
		winset(usr, "mainwindow", "is-maximized=true")
		winset(usr, "mainwindow", "menu=")
	else
		if(!(fullscreen & MAXIMAZED))
			winset(usr, "mainwindow", "is-maximized=false")
		winset(usr, "mainwindow", "titlebar=true")
		winset(usr, "mainwindow", "can-resize=true")
		winset(usr, "mainwindow", "menu=menu")

#undef MAXIMAZED
#undef FULLSCREEN

// ckey = datum/stat/leave_stat
var/global/list/disconnected_ckey_by_stat = list()
/client/proc/handle_connect()
	if(!global.disconnected_ckey_by_stat[ckey])
		return
	var/datum/stat/leave_stat/stat = global.disconnected_ckey_by_stat[ckey]
	qdel(stat)
	global.disconnected_ckey_by_stat -= ckey

/client/proc/handle_leave()
	if(!isliving(mob) || !mob.mind)
		return
	if(istype(mob.loc, /obj/machinery/cryopod))
		return
	var/datum/stat/leave_stat/stat = SSStatistics.get_leave_stat(mob.mind, "Disconnected", roundduration2text())

	global.disconnected_ckey_by_stat[ckey] = stat

/client/proc/change_view(new_size)
	if (isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	mob.reload_fullscreen()

/client/proc/open_filter_editor(atom/in_atom)
	if(holder)
		holder.filteriffic = new /datum/filter_editor(in_atom)
		holder.filteriffic.tgui_interact(mob)

/client/proc/open_particles_editor(atom/in_atom)
	if(holder)
		holder.particool = new /datum/particle_editor(in_atom)
		holder.particool.tgui_interact(mob)
