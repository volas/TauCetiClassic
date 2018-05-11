#define AUTOBAN_TIME 60//in minutes

var/global/geoip_query_counter = 0
var/global/geoip_next_counter_reset = 0
var/global/list/geoip_ckey_updated = list()

/datum/geoip_data
	var/holder = null
	var/status = null
	var/country = null
	var/countryCode = null
	var/region = null
	var/regionName = null
	var/city = null
	var/timezone = null
	var/isp = null
	var/mobile = null
	var/proxy = null
	var/ip = null

/datum/geoip_data/New(client/C, addr)
	INVOKE_ASYNC(src, .proc/get_geoip_data, C, addr)

/datum/geoip_data/proc/get_geoip_data(client/C, addr)
	set background = BACKGROUND_ENABLED

	if(!C || !addr)
		return

	if(!try_update_geoip(C, addr))
		return

	if(!C)
		return

	if(status == "updated")
		if(proxy == "true")
			var/reason = "No proxy allowed"
			AddBan(C.ckey, C.computer_id, reason, "taukitty", 1, AUTOBAN_TIME, C.mob.lastKnownIP)
			to_chat(C, "<span class='danger'><BIG><B>You have been banned by Tau Kitty.\nReason: [reason].</B></BIG></span>")
			to_chat(C, "\red This is a temporary ban, it will be removed in [AUTOBAN_TIME] minutes.")
			if(config.banappeals)
				to_chat(C, "<span class='red'>To try to resolve this matter head to [config.banappeals]</span>")
			else
				to_chat(C, "<span class='red'>No ban appeals URL has been set.</span>")
			ban_unban_log_save("Tau Kitty has banned [C.ckey]. - Reason: [reason] - This will be removed in [AUTOBAN_TIME] minutes.")
			log_admin("Tau Kitty has banned [C.ckey].\nReason: [reason]\nThis will be removed in [AUTOBAN_TIME] minutes.")
			message_admins("Tau Kitty has banned [C.ckey].\nReason: [reason]\nThis will be removed in [AUTOBAN_TIME] minutes.")
			DB_ban_record_2(BANTYPE_TEMP, C.mob, AUTOBAN_TIME, reason)
			del(C)
		else
			var/msg = "[holder] connected from ([country], [regionName], [city]) using ISP: ([isp]) with IP: ([ip]) Proxy: ([proxy])"
			log_access(msg)
			if(ticker.current_state > GAME_STATE_STARTUP && !(C.ckey in geoip_ckey_updated))
				geoip_ckey_updated |= C.ckey
				message_admins(msg)

/datum/geoip_data/proc/try_update_geoip(client/C, addr)
	if(!C || !addr)
		return

	if(C.holder && (C.holder.rights & R_ADMIN))
		status = "admin"
		return 0//Lets save calls.

	if(status != "updated")
		holder = C.ckey

		var/msg = geoip_check(addr)
		if(msg == "limit reached" || msg == "export fail")
			status = msg
			return 0

		for(var/data in msg)
			switch(data)
				if("country")
					country = msg[data]
				if("countryCode")
					countryCode = msg[data]
				if("region")
					region = msg[data]
				if("regionName")
					regionName = msg[data]
				if("city")
					city = msg[data]
				if("timezone")
					timezone = msg[data]
				if("isp")
					isp = msg[data]
				if("mobile")
					mobile = msg[data] ? "true" : "false"
				if("proxy")
					proxy = msg[data] ? "true" : "false"
				if("query")
					ip = msg[data]
		status = "updated"
	return 1

/proc/geoip_check(addr)
	if(world.time > geoip_next_counter_reset)
		geoip_next_counter_reset = world.time + 900
		geoip_query_counter = 0

	geoip_query_counter++
	if(geoip_query_counter > 130)
		return "limit reached"

	var/list/vl = world.Export("http://ip-api.com/json/[addr]?fields=205599")
	if (!("CONTENT" in vl) || vl["STATUS"] != "200 OK")
		return "export fail"

	var/msg = file2text(vl["CONTENT"])
	return json2list(msg)

#undef AUTOBAN_TIME