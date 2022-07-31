// CAPTAIN OUTFIT
/datum/outfit/job/captain
	name = OUTFIT_JOB_NAME("Captain")

	uniform = /obj/item/clothing/under/rank/captain
	shoes = /obj/item/clothing/shoes/brown
	head = /obj/item/clothing/head/caphat
	glasses = /obj/item/clothing/glasses/sunglasses

	l_ear = /obj/item/device/radio/headset/heads/captain
	belt = /obj/item/weapon/melee/chainofcommand

	r_hand_back = /obj/item/weapon/storage/box/ids
	l_pocket = /obj/item/device/pda/captain
	back_style = BACKPACK_STYLE_CAPTAIN

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty
		)

// HOP OUTFIT
/datum/outfit/job/hop
	name = OUTFIT_JOB_NAME("Head of Personnel")

	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/boots

	l_ear = /obj/item/device/radio/headset/heads/hop
	belt = /obj/item/device/pda/heads/hop

	r_hand_back = /obj/item/weapon/storage/box/ids

// PO

/datum/outfit/job/po
	name = OUTFIT_JOB_NAME("Pilot officer")

	head = /obj/item/clothing/head/soft/nt_pmc_cap
	uniform = /obj/item/clothing/under/rank/pilot_officer
	shoes = /obj/item/clothing/shoes/boots/nt_pmc_boots

	l_ear = /obj/item/device/radio/headset/headset_po
	belt = /obj/item/device/pda/heads

	implants = list(
		/obj/item/weapon/implant/mind_protect/loyalty,
		/obj/item/weapon/implant/obedience
		)