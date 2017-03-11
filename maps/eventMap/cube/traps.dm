//trigger_type варианты:
#define TRIGGER_TYPE_AREA 1					//при заходе в комнату(активируетс€ из area/entered
#define TRIGGER_TYPE_PROXIMITY 2			//при близости(в соседнем тайле)
#define TRIGGER_TYPE_ENTERED 3				//он наступил на ловушку

/obj/cube_trap

	anchored = 1

	var/trigger_type = TRIGGER_TYPE_ENTERED	//тип активации, варианты с комментами выше
	var/trigger_delay = 0					//«адержка срабатывани€ в 1/10 секунд, при 0 - мгновенно. 600 - минута
	var/trigger_cooldown = 0				// улдаун, дать жертве шанс убежать перед следующим срабатыванием
	var/trigger_activations = 1				// оличество активаций ловушки
	var/trigger_only_human = 0				//ƒолжно ли срабатывать только на людей, или еще на предметы?

	var/already_activated = 0				//флажок дл€ избежани€ нескольких одновременных активаций
	//invisibility = 101						//невидимость дл€ ловушки

	HasProximity(H as mob|obj)
		world << "HasProximity [H]"
		if(trigger_type != TRIGGER_TYPE_PROXIMITY)
			return
		Trigger(H)

	Crossed(H as mob|obj)
		world << "Crossed [H]"
		if(trigger_type != TRIGGER_TYPE_ENTERED)
			return
		Trigger(H)

	proc/Trigger(H as mob|obj)

		world << "Trigger [H]"

		if(already_activated)
			return

		if(trigger_activations <= 0)
			return

		if(!ishuman(H) && trigger_only_human)
			return

		already_activated = 1

		sleep(trigger_delay)

		Activate(H)
		trigger_activations--

		sleep(trigger_cooldown)

		already_activated = 0
		return

	proc/Activate(H as mob|obj)
		return

/*************************************************************************************/
//ѕростейший пример ловушки. ƒостаточно просто переопределить Activate
/obj/cube_trap/gibzone
	trigger_type = TRIGGER_TYPE_ENTERED
	trigger_delay = 10
	trigger_cooldown = 0
	trigger_activations = 1000
	trigger_only_human = 1

	Activate(var/mob/living/carbon/human/H)
		playsound(loc, 'sound/weapons/wave.ogg', 50)
		H.gib()

/*************************************************************************************/
//родительский класс, рабочие "гранаты" - ниже
/obj/cube_trap/chemtrap
	trigger_type = TRIGGER_TYPE_PROXIMITY
	trigger_delay = 10
	trigger_cooldown = 50
	trigger_activations = 1000
	trigger_only_human = 0

	var/list/beakers = new/list()
	var/affected_area = 3

	New()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

	Activate()
		//копипаст из химгранаты, так как € не разбираюсь в этом всем.
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

		if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				src.reagents.reaction(A, 1, 10)

/************************/

/obj/cube_trap/chemtrap/smoke

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B1.reagents.add_reagent("sacid", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2

/************************/

/obj/cube_trap/chemtrap/incendiary

	trigger_activations = 1//гореть после одной активации уже нечему будет

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B1.reagents.add_reagent("aluminum", 15)
		B1.reagents.add_reagent("fuel",20)
		B2.reagents.add_reagent("plasma", 15)
		B2.reagents.add_reagent("sacid", 15)
		B1.reagents.add_reagent("fuel",20)

		beakers += B1
		beakers += B2

/*************************************************************************************/



//Laser2.ogg дл€ лезвий