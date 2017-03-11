/area/cube
	requires_power = 0
	luminosity = 1
	//lighting_use_dynamic = 0
	icon = 'maps/eventMap/cube/areas.dmi'
	icon_state = "room"
	name = "cube"

/area/cube/corridor
	icon_state = "corridor"

/area/cube/room
	var/dangerous = 1 //используется ТОЛЬКО для генератора, чтоб знать оставить ли зону безопасной
	var/engaged = 0 //Занята ли комната ловушками, или нет. Определяется при наполнении комнат. Можно потом использовать при раздаче дополнительных ловушек, или еще где.

	Entered(H as mob|obj)
		..()
		if(!engaged) return
		for(var/obj/cube_trap/T in src)
			if(T.trigger_type == 1)
				T.Trigger(H)
			else
				break

/area/cube/room/room0
	dangerous = 0

/area/cube/room/room1

/area/cube/room/room2

/area/cube/room/room3

/area/cube/room/room4

/area/cube/room/room5

/area/cube/room/room6

/area/cube/room/room7

/area/cube/room/room8

/area/cube/room/room9

/area/cube/room/room10

/area/cube/room/room11

/area/cube/room/room12

/area/cube/room/room13

/area/cube/room/room14

/area/cube/room/room15

/area/cube/room/room16

/area/cube/room/room17

/area/cube/room/room18

/area/cube/room/room19

/area/cube/room/room20