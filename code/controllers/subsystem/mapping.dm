var/datum/subsystem/mapping/SSmapping

// How many structures will be spawned
#define SPACE_STRUCTURES_AMMOUNT 7
// Uncomment to enable debug output of structure coords
//#define SPACE_STRUCTURES_DEBUG 1

/datum/subsystem/mapping
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE

	var/datum/map_config/config
	var/datum/map_config/next_map_config

	var/const/max_secret_rooms = 3
	var/list/spawned_structures = list()

	// Z-manager stuff
	var/station_start  // should only be used for maploading-related tasks
	var/space_levels_so_far = 0
	var/list/z_list
	var/station_loaded = FALSE
	var/station_image = "exodus" // What image file to use for map displaying, stored in nano/images

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)

/datum/subsystem/mapping/Initialize(timeofday)
	config = load_map_config(error_if_missing = FALSE)
	station_image = config.station_image
	station_name = config.station_name
	system_name = config.system_name

	loadWorld()
	renameAreas()

	process_teleport_locs()			//Sets up the wizard teleport locations
	process_ghost_teleport_locs()	//Sets up ghost teleport locations.

	// Generate mining.
	make_mining_asteroid_secrets()
	populate_distribution_map()
	// Load templates
	preloadTemplates()
	// Space structures
	spawn_space_structures()
	..()

/datum/subsystem/mapping/proc/make_mining_asteroid_secrets()
	for(var/i in 1 to max_secret_rooms)
		make_mining_asteroid_secret()

/datum/subsystem/mapping/proc/populate_distribution_map()
	var/datum/ore_distribution/distro = new
	distro.populate_distribution_map()

/datum/subsystem/mapping/proc/spawn_space_structures()
	if(!levels_by_trait(ZTRAIT_SPACE_RUINS).len)
		return

	// picking structures to spawn
	var/list/possible = list()
	for(var/structure_id in spacestructures_templates)
		possible += structure_id

	var/list/picked_structures = list()
	while(possible.len && picked_structures.len < SPACE_STRUCTURES_AMMOUNT)
		var/structure_id = pick(possible)
		possible -= structure_id
		picked_structures += structure_id

	// structure spawning
	for (var/structure_id in picked_structures)
		var/datum/map_template/space_structure/structure = spacestructures_templates[structure_id]

		var/turf/T = find_spot(structure)
		if(T)
			// coords might point to any turf inside the structure and some extra deviation
			var/xcoord = T.x + rand(-structure.width / 2 - 10, structure.width / 2 + 10)
			var/ycoord = T.y + rand(-structure.height / 2 - 10, structure.height / 2 + 10)
			spawned_structures += list(list("id" = structure_id, "desc" = structure.desc, "turf" = T, "x" = xcoord, "y" = ycoord, "z" = T.z))
			structure.load(T, centered = TRUE, initBounds = FALSE)
#ifdef SPACE_STRUCTURES_DEBUG
			message_admins("[structure_id] was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")
#endif

/datum/subsystem/mapping/proc/find_spot(datum/map_template/space_structure/structure)
	var/structure_size = ceil(max(structure.width / 2, structure.height / 2))
	for (var/try_count in 1 to 10)
		var/turf/space/T = locate(rand(structure.width, world.maxx - structure.width), rand(structure.height, world.maxy - structure.height), pick(levels_by_trait(ZTRAIT_SPACE_RUINS)))
		if(!istype(T))
			continue

		if(locate(/turf/simulated) in orange(structure_size, T))
			continue
		if(locate(/obj) in orange(structure_size, T))
			continue

		return T
#ifdef SPACE_STRUCTURES_DEBUG
	message_admins("Couldn't find position for [structure.structure_id]")
#endif
	return null

/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT

	config = SSmapping.config
	next_map_config = SSmapping.next_map_config

#undef SPACE_STRUCTURES_AMMOUNT
#undef SPACE_STRUCTURES_ZLEVELS

#define INIT_ANNOUNCE(X) info(X)
/datum/subsystem/mapping/proc/LoadGroup(list/errorList, name, path, files, list/traits, list/default_traits, silent = FALSE)
	. = list()
	var/start_time = REALTIMEOFDAY

	if (!islist(files))  // handle single-level maps
		files = list(files)

	// check that the total z count of all maps matches the list of traits
	var/total_z = 0
	var/list/parsed_maps = list()
	for (var/file in files)
		var/full_path = "maps/[path]/[file]"
		//var/datum/parsed_map/pm = new(file(full_path))
		var/datum/map_template/pm = new(full_path)
		var/bounds = pm?.bounds
		if (!bounds)
			errorList |= full_path
			continue
		parsed_maps[pm] = total_z  // save the start Z of this file
		total_z += bounds[MAP_MAXZ] - bounds[MAP_MINZ] + 1

	if (!length(traits))  // null or empty - default
		for (var/i in 1 to total_z)
			traits += list(default_traits)
	else if (total_z != traits.len)  // mismatch
		INIT_ANNOUNCE("WARNING: [traits.len] trait sets specified for [total_z] z-levels in [path]!")
		if (total_z < traits.len)  // ignore extra traits
			traits.Cut(total_z + 1)
		while (total_z > traits.len)  // fall back to defaults on extra levels
			traits += list(default_traits)

	// preload the relevant space_level datums
	var/start_z = world.maxz + 1
	var/i = 0
	for (var/level in traits)
		add_new_zlevel("[name][i ? " [i + 1]" : ""]", level)
		++i

	// load the maps
	for (var/P in parsed_maps)
		var/datum/map_template/pm = P
		if (!pm.loadMap(start_z + parsed_maps[P]))
			errorList |= pm.mappath
	if(!silent)
		INIT_ANNOUNCE("Loaded [name] in [(REALTIMEOFDAY - start_time)/10]s!")
	return parsed_maps

/datum/subsystem/mapping/proc/loadWorld()
	//if any of these fail, something has gone horribly, HORRIBLY, wrong
	var/list/FailedZs = list()

	// ensure we have space_level datums for compiled-in maps
	InitializeDefaultZLevels()

	// load the station
	station_start = world.maxz + 1
	INIT_ANNOUNCE("Loading [config.map_name]...")
	LoadGroup(FailedZs, "Station", config.map_path, config.map_file, config.traits, ZTRAITS_STATION)
	station_loaded = TRUE

	while (space_levels_so_far < config.space_ruin_levels)
		++space_levels_so_far
		add_new_zlevel("Empty Area [space_levels_so_far]", ZTRAITS_SPACE)

	for (var/i in 1 to config.space_empty_levels)
		++space_levels_so_far
		add_new_zlevel("Empty Area [space_levels_so_far]", list(ZTRAIT_LINKAGE = CROSSLINKED))

	// load mining
	if(config.minetype == "asteroid")
		LoadGroup(FailedZs, "Asteroid", "asteroid", "asteroid.dmm", default_traits = ZTRAITS_ASTEROID)
	else if (!isnull(config.minetype))
		INIT_ANNOUNCE("WARNING: An unknown minetype '[config.minetype]' was set! This is being ignored! Update the maploader code!")

	if(config.load_junkyard)
		LoadGroup(FailedZs, "Junkyard", "junkyard", "junkyard.dmm", default_traits = list(ZTRAIT_JUNKYARD = TRUE))

	if(LAZYLEN(FailedZs))	//but seriously, unless the server's filesystem is messed up this will never happen
		var/msg = "RED ALERT! The following map files failed to load: [FailedZs[1]]"
		if(FailedZs.len > 1)
			for(var/I in 2 to FailedZs.len)
				msg += ", [FailedZs[I]]"
		msg += ". Yell at your server host!"
		INIT_ANNOUNCE(msg)

#undef INIT_ANNOUNCE

// Some areas use station name so we rename them here
/datum/subsystem/mapping/proc/renameAreas()
	if(!config)
		return

	if(config.system_name)
		areas_by_type[/area/shuttle/arrival/pre_game].name = "[config.system_name] Transfer Station 13"
	if(config.station_name)
		areas_by_type[/area/shuttle/arrival/station].name = config.station_name
		areas_by_type[/area/shuttle/officer/station].name = config.station_name

/datum/subsystem/mapping/proc/changemap(var/datum/map_config/VM)
	if(!VM.MakeNextMap())
		next_map_config = load_map_config(default_to_box = TRUE)
		message_admins("Failed to set new map with next_map.json for [VM.map_name]! Using default as backup!")
		return

	next_map_config = VM
	return TRUE