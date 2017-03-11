//trigger_type ��������:
#define TRIGGER_TYPE_AREA 1					//��� ������ � �������(������������ �� area/entered
#define TRIGGER_TYPE_PROXIMITY 2			//��� ��������(� �������� �����)
#define TRIGGER_TYPE_ENTERED 3				//�� �������� �� �������

/obj/cube_trap

	anchored = 1

	var/trigger_type = TRIGGER_TYPE_ENTERED	//��� ���������, �������� � ���������� ����
	var/trigger_delay = 0					//�������� ������������ � 1/10 ������, ��� 0 - ���������. 600 - ������
	var/trigger_cooldown = 0				//�������, ���� ������ ���� ������� ����� ��������� �������������
	var/trigger_activations = 1				//���������� ��������� �������
	var/trigger_only_human = 0				//������ �� ����������� ������ �� �����, ��� ��� �� ��������?

	var/already_activated = 0				//������ ��� ��������� ���������� ������������� ���������
	//invisibility = 101						//����������� ��� �������

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
//���������� ������ �������. ���������� ������ �������������� Activate
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
//������������ �����, ������� "�������" - ����
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
		//�������� �� ����������, ��� ��� � �� ���������� � ���� ����.
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

	trigger_activations = 1//������ ����� ����� ��������� ��� ������ �����

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



//Laser2.ogg ��� ������