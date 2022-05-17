extends Node

signal _on_validate_player_data_complete(player_name, player_data)

enum VERSION_COMP {SAME, OLDER, NEWER, BAD_KEYS, UNEVEN_KEYS}
var versionID = "0.0.4.00"


enum GAME_TYPES {CONSTRUCTED, DRAFT}
enum MATCH_TYPE {FREE_PLAY, TOURNAMENT}
enum DRAFT_TYPES {WINSTON, BOOSTER, SOLOMON}

enum ANIMATION_SPEEDS \
{
	NORMAL = 10,
	QUICK = 15,
	DOUBLE = 20,
	INSTANT = 9990
}

enum TURN_TIMES \
{
	FIFTEEN = 15
	THIRTY = 30,
	SIXTY = 60,
	NINETY = 90,
	ONE_TWENTY = 120,
	NONE = -1
}

enum GAME_TIMES \
{
	ONE = 60,
	FIVE = 5 * 60,
	TEN = 10 * 60,
	TWENTY = 20 * 60
}

var turnTimerMax : int = TURN_TIMES.NINETY
var gameTimerMax : int = GAME_TIMES.TEN
var animationSpeed : float = ANIMATION_SPEEDS.NORMAL / 10.0

var deckData := {}

enum GAME_MODE {NONE, LOBBY, PLAY, PRACTICE, DRAFTING, TOURNAMENT, DIRECT}

var gameMode : int = 0
var matchType : int = 0

var cardSlotScale = 1.5

var dumpPath = "user://dumps/"
var settingsPath = "user:/"
var settingsName = "settings"

var shaderPath = "user://shaders/"

func _ready():
	SilentWolf.Players.connect("sw_player_data_received", self, "sw_player_data_received")
	SilentWolf.Auth.connect("sw_logout_succeeded", self, "onLogOut")
	
	var json = FileIO.readJSON(settingsPath + "/" + settingsName + ".json")
		
	var settings = FileIO.readJSON(settingsPath + "/" + settingsName + ".json")
	var ok = verifySettings(settings)
	
	Settings.turnTimerMax = settings["turn_time"]
	Settings.gameTimerMax = settings["game_time"]
	Settings.animationSpeed = settings["anim_speed"]
	Server.ip = settings["ip_saved"]
	SoundEffectManager.setVolume(settings["sound_volume"])
	MusicManager.setVolume(settings["music_volume"])
	ShaderHandler.setShader(settings["shader"], false)
	
	if not ok:
		writeToSettings()

const default_sw_dict = {"decks":{}}
func sw_player_data_received(player_name, player_data):
	
	var should_push = false
	
	print("Received player data: ", player_data)
	if typeof(SilentWolf.Players.player_data) != TYPE_DICTIONARY or (SilentWolf.Players.player_data as Dictionary).empty():
		SilentWolf.Players.player_data = default_sw_dict
		should_push = true
		print("Deck is null/empty; setting")
		
	if not SilentWolf.Players.player_data.has("decks"):
		SilentWolf.Players.player_data["decks"] = {}
		should_push = true
		print("Key 'deck' dne; setting")
	
	if should_push:
		SilentWolf.Players.post_player_data(player_name, SilentWolf.Players.player_data)
	
	emit_signal("_on_validate_player_data_complete", player_name, SilentWolf.Players.player_data)

func onLogOut():
	SilentWolf.Players.clear_player_data()

func verifySettings(settings : Dictionary) -> bool:
	var ok = true
	if not settings.has("anim_speed"):
		settings["anim_speed"] = ANIMATION_SPEEDS.NORMAL / 10.0
		ok = false
	if not settings.has("turn_time"):
		settings["turn_time"] = TURN_TIMES.NINETY
		ok = false
	if not settings.has("game_time"):
		settings["game_time"] = GAME_TIMES.TEN
		ok = false
	if not settings.has("ip_saved"):
		settings["ip_saved"] = "127.0.0.1"
		ok = false
	if not settings.has("shader") or typeof(settings["shader"]) != TYPE_STRING:
		settings["shader"] = Settings.shaderPath + "default.shader"
		ok = false
	if not settings.has("sound_volume"):
		settings["sound_volume"] = -10
		ok = false
	if not settings.has("music_volume"):
		settings["music_volume"] = -20
		ok = false
		
	return ok
	

func writeToSettings():
	print("Saving user settings")
	FileIO.writeToJSON(settingsPath, settingsName, getSettingsDict())
	
func getSettingsDict() -> Dictionary:
	var rtn := \
	{
		"anim_speed":animationSpeed,
		"turn_time":turnTimerMax,
		"game_time":gameTimerMax,
		"ip_saved":Server.ip,
		"shader":ShaderHandler.currentShader,
		"sound_volume":SoundEffectManager.volume,
		"music_volume":MusicManager.volume
	}
	return rtn
	

static func compareVersion(comp1 : String, comp2 : String) -> int:
	var spl = comp1.split(".")
	var spl2 = comp2.split(".")
	
	if spl.size() != spl2.size():
		return VERSION_COMP.UNEVEN_KEYS
		
	for i in range(spl.size()):
		if spl[i].length() != spl2[i].length():
			return VERSION_COMP.UNEVEN_KEYS
		
	for i in range(spl.size()):
		if not spl[i].is_valid_integer() or not spl2[i].is_valid_integer():
			return VERSION_COMP.BAD_KEYS
			
	for i in range(spl.size()):
		if int(spl[i]) < 0 or int(spl2[i]) < 0:
			return VERSION_COMP.BAD_KEYS
		elif int(spl[i]) > int(spl2[i]):
			return VERSION_COMP.NEWER
		elif int(spl[i]) < int(spl2[i]):
			return VERSION_COMP.OLDER
			
	return VERSION_COMP.SAME
	
static func versionCompUnitTest():
	var string1 = "0.0.0.01"
	var string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.SAME)
	
	string1 = "4.00.20.3"
	string2 = "4.00.20.3"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.SAME)
	
	string1 = "30.123.0"
	string2 = "30.123.0"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.SAME)
	
	##################################################################################################################################################################
	
	string1 = "0.0.0"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.0.0.01"
	string2 = "0.0.0"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.00.0.02"
	string2 = "0.0.0.02"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.0.0.01"
	string2 = "0.0..01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	string1 = "0.0..01"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.UNEVEN_KEYS)
	
	##################################################################################################################################################################
	
	string1 = "0.0.f.01"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.BAD_KEYS)
	
	string1 = "0.00.0.20"
	string2 = "0.-1.0.20"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.BAD_KEYS)
	
	##################################################################################################################################################################
	
	string1 = "0.0.0.01"
	string2 = "0.0.0.02"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.OLDER)
	
	string1 = "0.00.0.01"
	string2 = "0.20.0.02"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.OLDER)
	
	##################################################################################################################################################################
	
	string1 = "0.20.0.02"
	string2 = "0.00.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.NEWER)
	
	string1 = "0.0.0.02"
	string2 = "0.0.0.01"
	print("Comp of ", string1, " and ", string2, " : ", compareVersion(string1, string2), " should return ", VERSION_COMP.NEWER)
	
	##################################################################################################################################################################
	
