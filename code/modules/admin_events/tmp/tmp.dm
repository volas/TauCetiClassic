/////////////////////////////// team_objects.dm

// Scrapheap Challenge: Space Station
// 1. Construction phase: 1 hour to build a space station (no atmos) using limited resources and disposal pipe dispensers to build warhead launchers with disposal pipes (Chute, Outlet and any other disposal pipe types).
// 2. Shelling phase: 1 hour to launch 40-50 warheads, primed with c4 detonators, using makeshift disposal delivery system (optionally: admin spawned mass drivers as additional warhead launcher type, if so - see the spawn conditions below).
// 3. Robust phase: 1 hour to completely eliminate surviving members of rival teams using melee combat (only makeshift weapons - no e-swords, no guns!).
// After the final phase has reached its time limit - the team with most surviving members wins.

// Participants options:
// Two teams on two opposite sides of the Scrapheap Challenge Arena (North-South/West-East) at least 5 team members per team, up to 10 team members per team.
// Four teams as originally intended - at least 5 team members per team, up to 10 team members per team.
// Make sure all teams has equal amount of team members!

// Optional mass driver conditions: Until it's possible for players to construct mass drivers and mass driver launch buttons - you can spawn them manually and change button/driver "id" variable in-game.
// If teams have 5 team members - one mass driver per team. If teams have 6 or more team members - two mass drivers per team. Each mass driver should have at least one, or two launch buttons in locations of players choice.
// Mass drivers and launch buttons can be spawned in any location within the allowed construction area (players can mark desired spawn locations with spray or crayons).

// Arena map itself is perfect for any space-based team challenges, including but not limited to the following game modes:
// 1. Scrapheap Challenge (as described above)
// 2. Battle of the Void (optimal if there are 20-40 participants):
// All participants form two opposing teams - instead of standard team equipment, players receive colored jumpsuits and emergency space suits (that can only prolong life for a few minutes until they breach from temperatures and pressure).
// One team gets Marauder mechs, the other gets Mauler mechs (equal stats - different look). Both teams receive identical mech modules to install on their improvised starships.
// Event locked z-layer will ensure all players will keep finding each other and flying around until only one team survives due to luck or ace piloting skills of some veterans.
// This event type is pretty entertaining thanks to mechs having very complex damage systems - a chance to randomly deflect the projectiles, as well as the ability to accumulate critical malfunctions that result in original deaths - cabin fire, oxygen leak, life support failure, navigation failure, short circuit, permanent equipment damage.
// For extra fun - try replacing mech icons with various starfighter types or even airplanes. Experiment to create balanced ship classes by playing with available equipment (e.g teams get two bombers, four interceptors, and four fighters, that look different and function differently).

//Team Challenge Satellite
//TCS is a state-of-the-art recreation facility that allows NanoTrasen employees and tourists to observe various Challenges from safe distance with comfort. For the convenience of visitors, stable energy supply is provided by CentCom.



//Adds Control Room ambience without making it separate area, as well as gives common sense advice for beginner event masters.

/obj/effect/landmark/teamchallenge
	name = "Control Room"
	icon_state = "x3"
	var/melody = ""//'sound/ambience/tcomms.ogg'
	var/message = "<b><span class='notice'>Before you press anything - make sure an equally balanced teams have been formed and fully equipped! Also inform the teams about your plans in advance to minimize the initial chaos. Let's get the show going!</span></b>"
	var/active = 1
	var/lchannel = 999

/obj/effect/landmark/teamchallenge/Crossed(mob/M)
	if(!active) return
	if(istype(M, /mob/living/carbon))
		M.playsound_local(null, melody, VOL_EFFECTS_MASTER, 20, FALSE, channel = lchannel, wait = TRUE, ignore_environment = TRUE)

//Glowing arrow direction affects decal color: Red - north. Yellow - east. Green - south. Blue - west.

//2558 Space Olympics by Uboaaaaaa

/obj/structure/sign/velocity_overlay/reklama/retro //If you are cleaning up the code, add it to general poster collection under var/global/list/legitposters
	name = "- 2558 Space Olympics"
	desc = "A poster glorifying forgotten Olympic champion - a golden medalist of 2558 in Robusting. Signed for a faithful fan, a champion's signature reads 'Katie'."
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "poster58_legit"





//ID cards

/obj/item/weapon/card/id/noteam
	name = "identification card"
	desc = "A card with orange lining, issued to NanoTrasen convicts."
	icon_state = "eng"
	item_state = "eng_id"

/obj/item/weapon/card/id/redteam
	name = "identification card"
	desc = "A card with red lining which shows courage and strength."
	icon_state = "sec"
	item_state = "sec_id"

/obj/item/weapon/card/id/yellowteam
	name = "identification card"
	desc = "A card with yellow lining which shows loyalty and optimism."
	icon_state = "cargoGold"
	item_state = "cargo_id"

/obj/item/weapon/card/id/greenteam
	name = "identification card"
	desc = "A card with green lining which shows harmony and dedication."
	icon_state = "id"
	item_state = "card-id"

/obj/item/weapon/card/id/blueteam
	name = "identification card"
	desc = "A card with blue lining which shows honor and wisdom."
	icon_state = "civ"
	item_state = "civ_id"



//Resource full stacks

/obj/item/stack/sheet/metal/fifty // remove
	amount = 50

/obj/item/stack/sheet/plasteel/fifty
	amount = 50

/obj/item/stack/sheet/wood/fifty
	amount = 50

/obj/item/stack/sheet/glass/fifty
	amount = 50

//There will be no air in these haphazard space stations, so spessmen won't be able to undress and eat food without killing themselves...

/obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood // replace with event species?
	name = "liquid junkfood autoinjector"
	desc = "A label on it reads: <i>Warning: Do not use more than one at a time, may cause nausea! Nutrition Facts: total fat 50%, total carbohydrate 30%, protein 20%</i>"
	icon_state = "auto_minig_t3"
	volume = 10

/obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("nutriment", 10)
	update_icon()


//Glowing magic mirror instead of lights that are easily abused for improvised stun batons roundstart.

/obj/structure/mirror/magic/glowing // fix with remap, remove
	light_range = 7
	light_power = 2

//"Let's have some fun!" - BartNixon

//The crate that held the Ark of the Covenant following its discovery by Indiana Jones in 1936.

/obj/structure/closet/crate/secure/woodseccrate/ark
	name = "9906753"
	desc = "A secure wooden crate. There is a large black stamp on the side that reads:<b><br>TOP SECRET<br>ARMY INTEL 9906753<br>DO NOT OPEN!</b>"

//Symbolic prize - Space Station equivalent of trophy cup. Very useful if you want to combat large fire or travel in space without wasting jetpack oxygen.

/*/obj/item/weapon/extinguisher/golden
	name = "golden fire extinguisher"
	desc = "A revered relic of the Founding Fathers. According to the legends - it possesses divine firefighting powers, as well as its healing touch is capable of curing minor brute damage."
	icon = 'code/modules/admin_events/tmp/challenge.dmi'
	icon_state = "gold_extinguisher0"
	item_state = "emergency_engi"
	hitsound = list('sound/effects/pray_chaplain.ogg')
	force = -777
	attack_verb = list("blessed", "consecrated")
	max_water = 777
	spray_range = 7*/



