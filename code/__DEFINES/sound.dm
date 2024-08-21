//volume channels for client's volume sliders.

// OOC audio
#define VOL_LOBBY_MUSIC (1<<0) // music in lobby
#define VOL_NOTIFICATIONS (1<<1) // mainly for ghosts, such as cloning ready, admin pm, etc
#define VOL_ADMIN_SOUNDS (1<<2) // admin sounds or music (fun category)

// IC audio
#define VOL_AMBIENT (1<<3) // ambient music/environment sounds
#define VOL_EFFECTS_MASTER (1<<4) // effects sounds // todo: rename to VOL_EFFECTS when you have time to push 500+ files change
#define VOL_VOICE_ANNOUNCEMENTS (1<<5) // voiced global announcements
#define VOL_MUSIC_INSTRUMENTS (1<<6) // music instruments!
#define VOL_SPAM_EFFECTS (1<<7) // separated channel for some spamming and annoying sounds so player can setup them separately (ex. tesla engine).
#define VOL_JUKEBOX (1<<8)

// converts raw preference volume (1-100) to non linear coefficient (0-1) we apply for SANITIZE_VOL(playsound volume) 
// to get final client volume before any others environment effects
// (don't change anything without heavy testing with debug, even 0.01 difference may break the sound or functions that connects with this).
#define VOL_LINEAR_TO_NON(vol_raw) ((20 ** clamp(vol_raw * 0.01, 0, 1.0)) - 0.99) / (20 - 0.99)
// environment settings can overload sound that uses 100% volume, so we cap default volume at 50%
// (which means our build is quieter than others!!!)
#define SANITIZE_VOL(vol) vol * 0.5

//sound channels, max is 1024
#define CHANNEL_AMBIENT 1
#define CHANNEL_AMBIENT_LOOP 2
#define CHANNEL_MUSIC 3
#define CHANNEL_ADMIN 777
#define CHANNEL_ANNOUNCE 802
#define CHANNEL_VOLUMETEST 803

//default byond sound environments
#define SOUND_ENVIRONMENT_NONE -1
#define SOUND_ENVIRONMENT_GENERIC 0
#define SOUND_ENVIRONMENT_PADDED_CELL 1
#define SOUND_ENVIRONMENT_ROOM 2
#define SOUND_ENVIRONMENT_BATHROOM 3
#define SOUND_ENVIRONMENT_LIVINGROOM 4
#define SOUND_ENVIRONMENT_STONEROOM 5
#define SOUND_ENVIRONMENT_AUDITORIUM 6
#define SOUND_ENVIRONMENT_CONCERT_HALL 7
#define SOUND_ENVIRONMENT_CAVE 8
#define SOUND_ENVIRONMENT_ARENA 9
#define SOUND_ENVIRONMENT_HANGAR 10
#define SOUND_ENVIRONMENT_CARPETED_HALLWAY 11
#define SOUND_ENVIRONMENT_HALLWAY 12
#define SOUND_ENVIRONMENT_STONE_CORRIDOR 13
#define SOUND_ENVIRONMENT_ALLEY 14
#define SOUND_ENVIRONMENT_FOREST 15
#define SOUND_ENVIRONMENT_CITY 16
#define SOUND_ENVIRONMENT_MOUNTAINS 17
#define SOUND_ENVIRONMENT_QUARRY 18
#define SOUND_ENVIRONMENT_PLAIN 19
#define SOUND_ENVIRONMENT_PARKING_LOT 20
#define SOUND_ENVIRONMENT_SEWER_PIPE 21
#define SOUND_ENVIRONMENT_UNDERWATER 22
#define SOUND_ENVIRONMENT_DRUGGED 23
#define SOUND_ENVIRONMENT_DIZZY 24
#define SOUND_ENVIRONMENT_PSYCHOTIC 25

#define SOUND_AREA_DEFAULT SOUND_ENVIRONMENT_ROOM

#define SOUND_AREA_STATION_HALLWAY SOUND_ENVIRONMENT_PARKING_LOT
#define SOUND_AREA_MAINTENANCE SOUND_ENVIRONMENT_SEWER_PIPE
#define SOUND_AREA_LARGE_METALLIC SOUND_ENVIRONMENT_QUARRY
#define SOUND_AREA_SMALL_METALLIC SOUND_ENVIRONMENT_BATHROOM
#define SOUND_AREA_ASTEROID SOUND_ENVIRONMENT_CAVE

#define EMP_DEFAULT 'sound/effects/EMPulse.ogg'
#define EMP_SEBB 'sound/effects/sound_effects_sebb_explode.ogg'
