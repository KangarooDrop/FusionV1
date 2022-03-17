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
		var error = file.open(path, file.READ)
		if error != 0:
			MessageManager.notify("Error opening json save file")
		else:
			text = file.get_as_text()
			var par = parse_json(text)
			if par != null:
				dict = par
			else:
				MessageManager.notify("Error parsing json save file")
	else:
		MessageManager.notify("Error finding json save file")
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
	var dumpFile = str(randi()) + ".txt"
	var error = file.open(Settings.dumpPath + dumpFile, File.WRITE)
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

func getAllFiles(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files
