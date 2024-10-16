// Approved manifest.
// +200 credits flat.
/datum/export/manifest_correct
	cost = CARGO_MANIFEST_COST
	unit_name = "approved manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_correct/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_approved() && !M.errors)
		return TRUE
	return FALSE

// Correctly denied manifest.
// Refunds the package cost minus the cost of crate.
/datum/export/manifest_error_denied
	cost = -CARGO_MANIFEST_COST * 2.5
	unit_name = "correctly denied manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_error_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_denied() && M.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error_denied/get_cost(obj/O)
	var/obj/item/weapon/paper/manifest/M = O
	return ..() + M.order_cost


// Erroneously approved manifest.
// Substracts the package cost.
/datum/export/manifest_error
	unit_name = "erroneously approved manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_error/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_approved() && M.errors)
		return TRUE
	return FALSE

/datum/export/manifest_error/get_cost(obj/O)
	var/obj/item/weapon/paper/manifest/M = O
	return -M.order_cost


// Erroneously denied manifest.
// Substracts the package cost minus the cost of crate.
/datum/export/manifest_correct_denied
	cost = CARGO_MANIFEST_COST * 2
	unit_name = "erroneously denied manifest"
	export_types = list(/obj/item/weapon/paper/manifest)

/datum/export/manifest_correct_denied/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/item/weapon/paper/manifest/M = O
	if(M.is_denied() && !M.errors)
		return TRUE
	return FALSE

/datum/export/manifest_correct_denied/get_cost(obj/O)
	var/obj/item/weapon/paper/manifest/M = O
	return ..() - M.order_cost
