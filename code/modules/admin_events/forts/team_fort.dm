// vend сюда тоже

//Ammunition teleporter - spawns the warhead and c4 detonator when activated through admin panel. - VoLas and Luduk were here.
var/list/bomb_spawners = list()

/obj/structure/bomb_telepad
	name = "warhead transporter"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle-o"
	anchored = 0

	var/list/spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/red, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/red
	name = "red warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/red, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/yellow
	name = "yellow warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/yellow, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/blue
	name = "blue warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/blue, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/green
	name = "green warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/green, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/atom_init()
	bomb_spawners += src

/obj/structure/bomb_telepad/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		to_chat(user, "<span class='notice'>You [anchored ? "unattached" : "attached"] the [src].</span>")
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		icon_state = anchored ? "pad-idle" : "pad-idle-o"

/obj/structure/bomb_telepad/proc/do_spawn()
	for(var/spawntype in spawntypes)
		new spawntype(loc)

//Team warheads - robust explosive fuel tanks, they don't beep and can't be detected unless seen directly. C4 primer adds random factor and fun calculations to it.

/obj/structure/reagent_dispensers/fueltank/warhead // todo new object type
	name = "warhead"
	desc = "Attach c4 to prime the explosion. Keep away from fire!"
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "warhead"

/obj/structure/reagent_dispensers/fueltank/warhead/explode()
	explosion(src.loc,3,4,5)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/warhead/red
	name = "red warhead"
	icon_state = "redwarhead"

/obj/structure/reagent_dispensers/fueltank/warhead/yellow
	name = "yellow warhead"
	icon_state = "yellowwarhead"

/obj/structure/reagent_dispensers/fueltank/warhead/green
	name = "green warhead"
	icon_state = "greenwarhead"

/obj/structure/reagent_dispensers/fueltank/warhead/blue
	name = "blue warhead"
	icon_state = "bluewarhead"

//iVend-o-mat / iVent / Event-o-mat - Softheart wuz here.
/obj/machinery/vending/ivend
	name = "iVend-o-mat"
	desc = "A specialized Scrapheap Challenge construction materials and equipment vendor."
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "ivend"
	products = list(/obj/item/stack/sheet/metal/fifty = 4, /obj/item/stack/sheet/glass/fifty = 4, /obj/item/stack/sheet/wood/fifty = 4, /obj/item/stack/sheet/plasteel/fifty = 2,
					/obj/item/weapon/rcd_ammo = 20, /obj/item/weapon/airlock_electronics = 15, /obj/item/weapon/stock_parts/cell/high = 15,
					/obj/item/weapon/module/power_control = 10, /obj/item/stack/cable_coil/random = 10, /obj/item/device/assembly/signaler = 10,
					/obj/item/device/assembly/infra = 10, /obj/item/device/assembly/prox_sensor = 10, /obj/item/weapon/weldpack = 5,
					/obj/item/weapon/storage/box/lights/mixed = 4, /obj/item/weapon/reagent_containers/food/snacks/soap/nanotrasen = 2, /obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood = 70)
	contraband = list(/obj/random/randomfigure = 1, /obj/random/plushie = 1)
	product_slogans = "It's iVend time!;iVend-o-mat - for all your iVend needs!;uBuild while iVend.;Hurry up, the time is running out!;Every iVend-o-mat unit is valuable - don't let anyone steal yours!;This iVend is sponsored by Tau Ceti branch of NanoTrasen Corporation!;iVend - a good way to get away from routine!;A new life awaits you in the Off-world colonies. The chance to begin again in a golden land of opportunity and adventure."
	product_ads = "It's iVend time!;iVend-o-mat - for all your iVend needs!;uBuild while iVend.;Don't be greedy - share with your teammates!"

//A disposal pipe dispenser without bin and outlet: Can't put fueltank in a bin, also fueltank warheads get stuck in the outlet section often.
/obj/machinery/pipedispenser/disposal/teamchallenge // move to vending?

/obj/machinery/pipedispenser/disposal/teamchallenge/ui_interact(user)
	var/dat = {"<b>Disposal Pipes</b><br><br>
		<A href='?src=\ref[src];dmake=0'>Pipe</A><BR>
		<A href='?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
		<A href='?src=\ref[src];dmake=2'>Junction</A><BR>
		<A href='?src=\ref[src];dmake=3'>Y-Junction</A><BR>
		<A href='?src=\ref[src];dmake=4'>Trunk</A><BR>
		<A href='?src=\ref[src];dmake=7'>Chute</A><BR>
		"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
