/*
	ѕро	разметку комнаты.
	метки распологаютс€ в комнате сверху-вниз, слева-направо.

	ƒл€ установки ловушки на определенные метки, используетс€
		set_traps
	¬ качестве параметра либо номера меток в list, либо специальные отрицательные коды
	-1 все метки
	-2 двери(3,11,23,15)
	-3 углы комнаты(1,5,21,25)
*/

/turf/unsimulated/wall/cubewall/
	name = "Wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cube"

/turf/simulated/floor/cubefloor/
	name = "Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "rcircuit"

/obj/machinery/cube_controller
	name = "cube controller"
	var/init_cube = 0

/obj/machinery/cube_controller/initialize()
	if(init_cube) return

	sleep(30)

	var/rcolor
	for(var/area/cube/room/R in world)
		if(R.engaged || !R.dangerous)
			continue

		rcolor = pick("bcircuit", "rcircuit", "ycircuit", "gcircuit")

		for(var/turf/simulated/floor/cubefloor/F in R)
			F.icon_state = rcolor

		set_traps(13, /obj/cube_trap/chemtrap/smoke, R)
		//var/traptype = picktrap()//реализовать когда будут ловушки
		//var/positions = get_pos(traptype)

	init_cube = 1

/obj/machinery/cube_controller/New()
	initialize() //если мы подгружаем во врем€ раунда, необходимо вызвыть инициалищацию контроллера самим

/obj/machinery/cube_controller/proc/set_traps(var/positions, var/type, var/area/cube/room/R)

	var/list/trapmarks = list()

	if(islist(positions))
		trapmarks = positions
	else if(positions < 0)
		switch(positions)
			if(-1) trapmarks = list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)
			if(-2) trapmarks = list(3,11,15,23)	//двери
			if(-3) trapmarks = list(1,5,21,25)	//углы
	else if(positions > 0 && positions <=25)
		trapmarks.Add(positions)

	for(var/obj/effect/landmark/cube/L in R)
		if(text2num(L.name) in trapmarks)
			new type(L.loc)

	R.engaged = 1

/obj/machinery/cube_controller/proc/pick_trap()
	return