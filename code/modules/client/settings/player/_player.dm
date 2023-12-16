/datum/pref/player
	domain = PREF_DOMAIN_PLAYER

/////////
/datum/pref/player/ui
	category = "UI"

/datum/pref/player/ui/aooccolor
	name = "aooccolor"
	value_type = PREF_TYPE_HEX
	value = "#ffffff"

/datum/pref/player/ui/test_text
	name = "test text"
	value_type = PREF_TYPE_TEXT
	value = "text"

/datum/pref/player/ui/test_choice
	name = "test choice"
	value_type = PREF_TYPE_CHOICE
	value = 1
	value_variations = list(1, 2, 3, 4 ,5)

/*/parallax
	value_type = PREF_TYPE_CHOICE
	value_variations = list(1, 2, 3, 4 ,5)
*/

///datum/pref/player/graphics
