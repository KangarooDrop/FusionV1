extends Node2D


#"user://decks/" + fileName + ".json"

func writeToJSON(path : String, fileName : String, data : Dictionary, makeFolders = false) -> int:
	
	if makeFolders:
		var directory = Directory.new( )
		directory.make_dir_recursive(path)
	
	var file = File.new()
	var error = file.open(path + "/" + fileName + ".json", File.WRITE)
	if error != 0:
		#print("ERROR: writing to file at path " + path + "/" + fileName + "  :  " + str(error))
		
		if not makeFolders:
			var errorNew = writeToJSON(path, fileName, data, true)
			return errorNew
		else:
			return error
		
	file.store_string(JSON.print(data, "  "))
	file.close()
	
	return 0

func readJSON(path : String) -> Dictionary:
	var file := File.new()
	var dict : Dictionary
	var text
	if file.file_exists(path):
		file.open(path, file.READ)
		text = file.get_as_text()
		var par = parse_json(text)
		if par != null:
			dict = par
		else:
			MessageManager.notify("Error parsing json save file")
		file.close()
	return dict

func getDataLog(path : String) -> Array:
	var file := File.new()
	file.open(path, File.READ)
	var rtn = []
	if file.file_exists(path):
		while not file.eof_reached():
			var text = file.get_line()
			rtn.append(text)
	else:
		MessageManager.notify("Error parsing game log file")
	file.close()
		
	return rtn
	

func dumpDataLog(gameLog : Array, makeFolders = false) -> int:
	
	if makeFolders:
		var directory = Directory.new( )
		directory.make_dir_recursive(Settings.dumpPath)
	
	var file = File.new()
	var error = file.open(Settings.dumpPath + Settings.dumpFile, File.WRITE)
	if error != 0:
		if not makeFolders:
			return dumpDataLog(gameLog, true)
		else:
			print("ERROR DUMPING GAME LOG")
			return error
		
	
	for i in range(gameLog.size()):
		var string = gameLog[i]
		if i != gameLog.size() - 1:
			string += "\n"
		file.store_string(string)
		
	file.close()
	
	return 0
