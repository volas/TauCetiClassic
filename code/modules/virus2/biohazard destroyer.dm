/obj/machinery/disease2/biodestroyer
	name = "Biohazard destroyer"
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposalbio"
	var/list/accepts = list(/obj/item/clothing,/obj/item/weapon/virusdish/,/obj/item/weapon/cureimplanter,/obj/item/weapon/diseasedisk,/obj/item/weapon/reagent_containers)
	density = 1
	anchored = 1

/obj/machinery/disease2/biodestroyer/attackby(obj/I, mob/user)
	for(var/path in accepts)
		if(I.type in typesof(path))
			user.drop_item()
			qdel(I)
			overlays += image('icons/obj/pipes/disposal.dmi', "dispover-handle")
			return
	user.drop_item()
	I.loc = src.loc

	for(var/mob/O in hearers(src, null))
		O.show_message("[bicon(src)] \blue The [src.name] beeps", 2)
