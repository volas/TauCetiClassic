/obj/machinery/account_database
	name = "Accounts uplink terminal"
	desc = "Access transaction logs, account data and all kinds of other financial records."
	icon = 'icons/obj/computer.dmi'
	icon_state = "aiupload"
	density = TRUE
	anchored = TRUE
	req_one_access = list(access_hop, access_captain, access_cent_captain)
	allowed_checks = ALLOWED_CHECK_NONE
	var/receipt_num
	var/machine_id = ""
	var/obj/item/weapon/card/id/held_card
	var/datum/money_account/detailed_account_view
	var/creating_new_account = 0
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NOVICE)

/obj/machinery/account_database/proc/get_access_level()
	if (!held_card)
		return 0
	if(access_cent_captain in held_card.access)
		return 2
	else if((access_hop in held_card.access) || (access_captain in held_card.access))
		return 1

/obj/machinery/account_database/proc/create_transation(target, reason, amount)
	var/datum/transaction/T = new()
	T.target_name = target
	T.purpose = reason
	T.amount = amount
	T.date = current_date_string
	T.time = worldtime2text()
	T.source_terminal = machine_id
	return T

/obj/machinery/account_database/proc/accounting_letterhead(report_name)
	return {"
		<center><h1><b>[report_name]</b></h1></center>
		<center><small><i>[station_name()] Accounting Report</i></small></center>
		<hr>
		<u>Generated By:</u> [held_card.registered_name], [held_card.assignment]<br>
	"}

/obj/machinery/account_database/atom_init()
	machine_id = "[station_name()] Acc. DB #[num_financial_terminals++]"
	. = ..()

/obj/machinery/account_database/attackby(obj/O, mob/user)
	if(!istype(O, /obj/item/weapon/card/id))
		return ..()

	if(!held_card)
		user.drop_from_inventory(O, src)
		held_card = O

		nanomanager.update_uis(src)

	attack_hand(user)

/obj/machinery/account_database/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null)
	var/data[0]
	data["src"] = "\ref[src]"
	data["id_inserted"] = !!held_card
	data["id_card"] = held_card ? text("[held_card.registered_name], [held_card.assignment]") : "-----"
	data["access_level"] = get_access_level()
	data["machine_id"] = machine_id
	data["creating_new_account"] = creating_new_account
	data["detailed_account_view"] = !!detailed_account_view
	data["station_account_number"] = station_account.account_number
	data["transactions"] = null
	data["accounts"] = null
	data["cargo_export_tax"] = SSeconomy.tax_cargo_export

	if (detailed_account_view)
		data["account_number"] = detailed_account_view.account_number
		data["owner_name"] = detailed_account_view.owner_name
		data["money"] = detailed_account_view.money
		data["suspended"] = detailed_account_view.suspended

		var/list/trx[0]
		for (var/datum/transaction/T in detailed_account_view.transaction_log)
			trx.Add(list(list(\
				"date" = T.date, \
				"time" = T.time, \
				"target_name" = T.target_name, \
				"purpose" = T.purpose, \
				"amount" = T.amount, \
				"source_terminal" = T.source_terminal)))

		if (trx.len > 0)
			data["transactions"] = trx

	var/list/accounts[0]
	for(var/i=1, i<=all_money_accounts.len, i++)
		var/datum/money_account/D = all_money_accounts[i]
		if(D.hidden)
			continue
		accounts.Add(list(list(\
			"account_number"=D.account_number,\
			"owner_name"=D.owner_name,\
			"suspended"=D.suspended ? "SUSPENDED" : "",\
			"account_index"=i)))

	if (accounts.len > 0)
		data["accounts"] = accounts

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "accounts_terminal.tmpl", src.name, 400, 640)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/account_database/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "main")

	if(href_list["choice"])
		switch(href_list["choice"])
			if("create_account")
				creating_new_account = 1

			if("add_funds")
				var/amount = input("Enter the amount you wish to add", "Silently add funds") as num
				if(detailed_account_view)
					detailed_account_view.adjust_money(amount)

			if("change_export_tax")
				var/amount = input("Enter the percent you want to set a tax to", "Export Tax %") as num
				amount = clamp(amount, 0, 100)
				SSeconomy.tax_cargo_export = amount

			if("remove_funds")
				var/amount = input("Enter the amount you wish to remove", "Silently remove funds") as num
				if(detailed_account_view)
					detailed_account_view.adjust_money(-amount)

			if("toggle_suspension")
				if(detailed_account_view)
					detailed_account_view.suspended = !detailed_account_view.suspended

			if("finalise_create_account")
				var/account_name = href_list["holder_name"]
				var/starting_funds = min(max(text2num(href_list["starting_funds"]), 0), station_account.money)
				create_account(account_name, starting_funds, src)
				if(starting_funds > 0)
					//subtract the money
					station_account.money -= starting_funds

					//create a transaction log entry
					var/trx = create_transation(account_name, "New account activation", "([starting_funds])")
					station_account.transaction_log.Add(trx)

				ui.close()
				creating_new_account = 0
			if("insert_card")
				if(held_card)
					held_card.loc = src.loc

					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(held_card)
					held_card = null

				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card/id))
						var/obj/item/weapon/card/id/C = I
						usr.drop_from_inventory(C, src)
						held_card = C

			if("view_account_detail")
				var/index = text2num(href_list["account_index"])
				if(index && index <= all_money_accounts.len)
					var/datum/money_account/MA = all_money_accounts[index]
					if(!MA.hidden)
						detailed_account_view = all_money_accounts[index]

			if("view_accounts_list")
				detailed_account_view = null
				creating_new_account = 0

			if("revoke_payroll")
				var/funds = detailed_account_view.money
				var/account_trx = create_transation(station_account.owner_name, "Revoke payroll", "([funds])")
				var/station_trx = create_transation(detailed_account_view.owner_name, "Revoke payroll", funds)

				station_account.adjust_money(funds)
				detailed_account_view.money = 0

				detailed_account_view.transaction_log.Add(account_trx)
				station_account.transaction_log.Add(station_trx)

			if("print")
				var/text
				var/obj/item/weapon/paper/P = new(loc)
				if (detailed_account_view)
					P.name = "account #[detailed_account_view.account_number] details"
					var/title = "Account #[detailed_account_view.account_number] Details"
					text = {"
						[accounting_letterhead(title)]
						<u>Holder:</u> [detailed_account_view.owner_name]<br>
						<u>Balance:</u> $[detailed_account_view.money]<br>
						<u>Status:</u> [detailed_account_view.suspended ? "Suspended" : "Active"]<br>
						<u>Transactions:</u> ([detailed_account_view.transaction_log.len])<br>
						<table>
							<thead>
								<tr>
									<td>Timestamp</td>
									<td>Target</td>
									<td>Reason</td>
									<td>Value</td>
									<td>Terminal</td>
								</tr>
							</thead>
							<tbody>
						"}

					for (var/datum/transaction/T in detailed_account_view.transaction_log)
						text += {"
									<tr>
										<td>[T.date] [T.time]</td>
										<td>[T.target_name]</td>
										<td>[T.purpose]</td>
										<td>[T.amount]</td>
										<td>[T.source_terminal]</td>
									</tr>
							"}

					text += {"
							</tbody>
						</table>
						"}

				else
					P.name = "financial account list"
					text = {"
						[accounting_letterhead("Financial Account List")]

						<table>
							<thead>
								<tr>
									<td>Account Number</td>
									<td>Holder</td>
									<td>Balance</td>
									<td>Status</td>
								</tr>
							</thead>
							<tbody>
					"}

					for(var/i=1, i<=all_money_accounts.len, i++)
						var/datum/money_account/D = all_money_accounts[i]
						text += {"
								<tr>
									<td>#[D.account_number]</td>
									<td>[D.owner_name]</td>
									<td>$[D.money]</td>
									<td>[D.suspended ? "Suspended" : "Active"]</td>
								</tr>
						"}

					text += {"
							</tbody>
						</table>
					"}

				P.info = text
				P.update_icon()
				state("The terminal prints out a report.")
