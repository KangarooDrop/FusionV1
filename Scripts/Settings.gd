extends Node

var versionID = "0.00.00.03"
enum VERSION_COMP {SAME, OLDER, NEWER, BAD_KEYS, UNEVEN_KEYS}
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
	

var playAnimations = true
var selectedDeck = ""
var path = "user://decks/"

var dumpPath = "user://dumps/"
var dumpFile = "x_.txt"

var gameMode : int
