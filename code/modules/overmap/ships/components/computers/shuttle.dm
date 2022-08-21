/obj/machinery/computer/shuttle_control
	name = "general shuttle control console"
	desc = "Used to control spacecraft that are designed to move between local sectors in open space."


/obj/machinery/computer/shuttle_control/attack_hand(mob/user)
	user.set_machine(src)
	tgui_interact(user)

/obj/machinery/computer/shuttle_control/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Shuttle", name)
		ui.open()

