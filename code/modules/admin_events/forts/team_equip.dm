// Team space suits - moded ERT rigs, but with equal stats. Suits contain medscanners to quickly evaluate if they should use their dying team member as spare mass driver projectile.
/obj/item/clothing/head/helmet/space/rig/ert/scrapheap
	name = "scrapheap team helmet"
	desc = "A helmet worn by the team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_stealth"
	item_state = "ert_stealth"
	//item_color = "ert_stealth"//todo
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 30, bio = 100, rad = 60)
	light_color = "#a0a080"
	action_button_name = "Toggle Helmet Visor Light" // todo cleanup

/obj/item/clothing/suit/space/rig/ert/scrapheap
	name = "scrapheap team suit"
	desc = "A suit worn by the team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_stealth"
	item_state = "ert_stealth"
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 30, bio = 100, rad = 60)
	breach_threshold = 25
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/device/healthscanner)

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/red
	name = "red team helmet"
	desc = "A helmet worn by the red team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_security"
	item_state = "ert_security"
	//item_color = "ert_security"//todo

/obj/item/clothing/suit/space/rig/ert/scrapheap/red
	name = "red team suit"
	desc = "A suit worn by the red team members of Space Scrapheap Challenge."
	icon_state = "ert_security"
	item_state = "ert_security"

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/yellow
	name = "yellow team helmet"
	desc = "A helmet worn by the yellow team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_engineer"
	item_state = "ert_engineer"
	//item_color = "ert_engineer"//todo

/obj/item/clothing/suit/space/rig/ert/scrapheap/yellow
	name = "yellow team suit"
	desc = "A suit worn by the yellow team members of Space Scrapheap Challenge."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/green // no green suits :(
	name = "green team helmet"
	desc = "A helmet worn by the white... I mean green team members of Space Scrapheap Challenge. Looks like the green paint has ran out."
	icon_state = "rig0-ert_medical"
	item_state = "ert_medical"
	//item_color = "ert_medical"//todo

/obj/item/clothing/suit/space/rig/ert/scrapheap/green
	name = "green team suit"
	desc = "A suit worn by the white... I mean green team members of Space Scrapheap Challenge. Looks like the green paint has ran out."
	icon_state = "ert_medical"
	item_state = "ert_medical"

/obj/item/clothing/head/helmet/space/rig/ert/scrapheap/blue
	name = "blue team helmet"
	desc = "A helmet worn by the blue team members of Space Scrapheap Challenge."
	icon_state = "rig0-ert_commander"
	item_state = "ert_commander"
	//item_color = "ert_commander"//todo

/obj/item/clothing/suit/space/rig/ert/scrapheap/blue
	name = "blue team suit"
	desc = "A suit worn by the blue team members of Space Scrapheap Challenge."
	icon_state = "ert_commander"
	item_state = "ert_commander"

// Team toolboxes with all the essentials.
/obj/item/weapon/storage/toolbox/scrapheap
	name = "challenge toolbox"
	desc = "It contains almost everything you need to build your own space station."
	icon_state = "syndicate"
	item_state = "toolbox_syndi"

/obj/item/weapon/storage/toolbox/scrapheap/atom_init()
	. = ..() // todo cleanup
	new /obj/item/weapon/rcd/scrapheap(src)
	new /obj/item/weapon/stock_parts/cell/hyper(src)
	new /obj/item/weapon/module/power_control(src)
	new /obj/item/device/multitool(src)
	new /obj/item/stack/cable_coil/random(src)
	/*new /obj/item/weapon/extinguisher/mini(src)*/
	new /obj/item/weapon/airlock_painter(src)
	new /obj/item/toy/crayon/spraycan(src)

/obj/item/weapon/storage/toolbox/scrapheap/red
	name = "red challenge toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/scrapheap/yellow
	name = "yellow challenge toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/toolbox/scrapheap/green
	name = "green challenge toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"
	color = "#00ff00"

/obj/item/weapon/storage/toolbox/scrapheap/blue
	name = "blue challenge toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

// 150 matter RCD - allows to build exactly one average sized room with an airlock.
/obj/item/weapon/rcd/scrapheap
	name = "overcharged rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor and basic airlocks."
	matter = 150
