// Returns true if val is from min to max, inclusive.
#define ISINRANGE(val, min, max) (min <= val && val <= max)



#define SHUTTLE_RECALL "recalled"
#define SHUTTLE_CALL "called"
#define SHUTTLE_STRANDED "stranded"
#define SHUTTLE_ESCAPE "escape"




//Shuttle flying state
#define SHUTTLE_DOCKED "docked"
#define SHUTTLE_IDLE "idle"
#define SHUTTLE_IGNITING "igniting"
#define SHUTTLE_RECHARGING "recharging"
#define SHUTTLE_PREARRIVAL "pre-arrival"
#define SHUTTLE_IN_HYPERSPACE "in hyperspace"



#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"	
#define COMSIG_GLOB_SHUTTLE_TAKEOFF "!shuttle_take_off"

//Rotation params
#define ROTATE_DIR 1
#define ROTATE_SMOOTH 2
#define ROTATE_OFFSET 4

//Docking error flags
#define DOCKING_SUCCESS 0
#define DOCKING_BLOCKED (1<<0)
#define DOCKING_IMMOBILIZED (1<<1)
#define DOCKING_AREA_EMPTY (1<<2)
#define DOCKING_NULL_DESTINATION (1<<3)
#define DOCKING_NULL_SOURCE (1<<4)

//Docking turf movements
#define MOVE_TURF 1
#define MOVE_AREA 2
#define MOVE_CONTENTS 4

// shuttle signals
#define COMSIG_SHUTTLE_SETMODE "shuttle_setmode"

// Shuttle return values
#define SHUTTLE_CAN_DOCK "can_dock"
#define SHUTTLE_NOT_A_DOCKING_PORT "not a docking port"
#define SHUTTLE_DWIDTH_TOO_LARGE "docking width too large"
#define SHUTTLE_WIDTH_TOO_LARGE "width too large"
#define SHUTTLE_DHEIGHT_TOO_LARGE "docking height too large"
#define SHUTTLE_HEIGHT_TOO_LARGE "height too large"
#define SHUTTLE_RESERVED "dock is reserved"
#define SHUTTLE_ALREADY_DOCKED "we are already docked"
#define SHUTTLE_SOMEONE_ELSE_DOCKED "someone else docked"

#define SHUTTLE_EXPLORATION "daedalus"

//Shuttle defaults
#define SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE /area/shuttle/controllable
#define SHUTTLE_DEFAULT_UNDERLYING_AREA /area/space


#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))