// Returns true if val is from min to max, inclusive.
#define ISINRANGE(val, min, max) (min <= val && val <= max)


#define SHUTTLE_IDLE "idle"
#define SHUTTLE_IGNITING "igniting"
#define SHUTTLE_RECALL "recalled"
#define SHUTTLE_CALL "called"
#define SHUTTLE_DOCKED "docked"
#define SHUTTLE_STRANDED "stranded"
#define SHUTTLE_ESCAPE "escape"
#define SHUTTLE_ENDGAME "endgame: game over"
#define SHUTTLE_RECHARGING "recharging"
#define SHUTTLE_PREARRIVAL "pre-arrival"


#define SHUTTLE_EXPLORATION "daedalus"

//Shuttle defaults
#define SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE /area/shuttle
#define SHUTTLE_DEFAULT_UNDERLYING_AREA /area/space