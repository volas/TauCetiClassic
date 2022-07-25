/area/centcom/teamchallenge
	name = "Team Challenge Satellite"
	icon_state = "observatory"
	looped_ambience = 'sound/ambience/loop_regular.ogg' // todo rename file

//Colorful lights
/obj/machinery/light/small/green
	name = "green light fixture"
	desc = "A small green lighting fixture."
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#00cc00"
	light_color = "#00cc00"
	nightshift_light_color = "#00cc00"

/obj/machinery/light/small/ultramarine
	name = "ultramarine light fixture"
	desc = "A small ultramarine lighting fixture... For the Emprah!"
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#0000ff"
	light_color = "#0000ff"
	nightshift_light_color = "#0000ff"

/obj/machinery/light/small/purple
	name = "purple light fixture"
	desc = "A small purple lighting fixture."
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#ff00ff"
	light_color = "#ff00ff"
	nightshift_light_color = "#ff00ff"

//Ladders that limit the construction areas while allowing easier movement in space. Use Del-all when construction phase is over.
/obj/effect/decal/ladders // todo replace with catwalk
	name = "space ladder"
	desc = "It marks the construction area and improves movement of astronauts in the vacuum of space."
	density = 1
	anchored = 1
	layer = 2
	light_range = 3
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "ladders"

/obj/effect/decal/cleanable/glowingarrow
	name = "glowing arrow"
	desc = "Your space station weapon arrays shall be directed this way! You can remove this arrow with soap."
	density = 0
	anchored = 1
	layer = 2
	light_range = 7
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "arrow"

//If you change camera computers networks manually in-game with VV (security, detective, entertainment and others) - the networks won't switch. So here is a dedicated telescreen that can be spawned anywhere anytime.
/obj/machinery/computer/security/telescreen/entertainment/teamchallenge
	name = "entertainment monitor"
	desc = "Hopefully that thing can broadcast something interesting."
	network = list("ERT")

//Fake shield barrier preventing teams from attacking each other during construction and bombardment phases. Can be toggled via admin panel. - VoLas and Luduk were here too.

var/event_field_stage = 1 //1 - nothing, 2 - objects, 3 - all

var/list/team_shields = list()

/proc/set_event_field_stage(value)
	event_field_stage = value

	for(var/obj/effect/decal/teamchallenge/shield in team_shields)
		shield.update_icon()

/obj/effect/decal/teamchallenge
	name = "force field"
	desc = "It prevents teams from attacking each other too early. Nothing can pass through the field."
	density = 0
	anchored = 1
	layer = 2
	light_range = 3
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "energyshield"
	color = "#66ccff"

/obj/effect/decal/teamchallenge/atom_init()
	. = ..()
	team_shields += src
	update_icon()

/obj/effect/decal/teamchallenge/Destroy()
	team_shields -= src
	return ..()

/obj/effect/decal/teamchallenge/ex_act()
	return

/obj/effect/decal/teamchallenge/CanPass(atom/movable/mover)
	if(event_field_stage==3)
		return 1
	else if(isobj(mover) && event_field_stage==2)
		return 1
	else
		return 0

/obj/effect/decal/teamchallenge/update_icon()
	switch(event_field_stage)
		if(1)
			desc = "It prevents teams from attacking each other too early. Nothing can pass through the field."
			icon_state = "energyshield"
			color = "#66ccff"
		if(2)
			desc = "Looks like this field is less dense than usual. Only inanimate objects can pass through the field."
			icon_state = "energyshield"
			color = "#ffcc66"
		if(3)
			desc = "Robust at last! Anything can pass through the field when it's green."
			icon_state = "energyshield"
			color = "#00ff00"
