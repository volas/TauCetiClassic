/obj/mecha/medical/atom_init()
	. = ..()
	var/turf/T = get_turf(src)
	if(T.z != ZLEVEL_CENTCOMM)
		new /obj/item/mecha_parts/mecha_tracking(src)


/obj/mecha/medical/mechturn(direction)
	dir = direction
	playsound(src, 'sound/mecha/mechmove01.ogg', VOL_EFFECTS, 40)
	return 1

/obj/mecha/medical/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src, 'sound/mecha/mechstep.ogg', VOL_EFFECTS, 25)
	return result

/obj/mecha/medical/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src, 'sound/mecha/mechstep.ogg', VOL_EFFECTS, 25)
	return result
