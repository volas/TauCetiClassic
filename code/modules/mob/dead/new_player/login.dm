/mob/dead/new_player/Login()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	..()

	if(join_motd)
		to_chat(src, "<div class='motd'>[join_motd]</div>", handle_whitespace = FALSE)
	if(join_test_merge)
		to_chat(src, "<div class='test_merges'>[join_test_merge]</div>", handle_whitespace = FALSE)
	if(host_announces)
		to_chat(src, "<div class='host_announces emojify linkify'>[host_announces]</div>", handle_whitespace = FALSE)

	sight |= SEE_TURFS

	new_player_panel()
	playsound_lobbymusic()
//	handle_privacy_poll() // commented cause polls are kinda broken now, needs refactoring
